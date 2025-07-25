import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:radio_player/radio_player.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:url_launcher/link.dart';
import 'package:volume_controller/volume_controller.dart';

import '../utilities/constants.dart';
import '../utilities/theme_provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  PlaybackState _playbackState = PlaybackState.paused;
  Metadata? _metadata;

  StreamSubscription? _playbackStateSubscription;
  StreamSubscription? _metadataSubscription;

  bool isStopped = false;

  double _currentVolume = 0.5;

  Timer? _timer;
  double _selectedTime = 25.0;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    isStopped = false;
    initRadioPlayer();

    AudioSession.instance.then((session) {
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              RadioPlayer.pause();
              break;
            case AudioInterruptionType.duck:
              VolumeController.instance.setVolume(_currentVolume * 0.3);
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.pause:
              RadioPlayer.play();
              break;
            case AudioInterruptionType.duck:
              VolumeController.instance.setVolume(_currentVolume);
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      session.becomingNoisyEventStream.listen((_) {
        RadioPlayer.pause();
      });
    });

    VolumeController.instance.addListener((volume) {
      setState(() {
        _currentVolume = volume;
      });
    });

    VolumeController.instance.getVolume().then((volume) {
      setState(() {
        _currentVolume = volume;
      });
    });
  }

  Future<void> initRadioPlayer() async {
    await RadioPlayer.setStation(
      title: 'Radio Evangelo Torino',
      url: 'http://199.247.7.81:8000/radio.mp3',
      logoAssetPath: 'lib/assets/logo.png',
    );

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    bool success = await session.setActive(true);
    if (!success) {
      debugPrint('AudioSession non attivata. Interrompo.');
      return;
    }

    _playbackStateSubscription =
        RadioPlayer.playbackStateStream.listen((playbackState) {
      setState(() {
        _playbackState = playbackState;
      });
    });

    _metadataSubscription = RadioPlayer.metadataStream.listen((metadata) {
      setState(() {
        _metadata = metadata;
      });
    });

    isStopped ? null : await RadioPlayer.play();
  }

  Future<void> setVolume(double volume) async {
    VolumeController.instance.setVolume(volume);
    setState(() {
      _currentVolume = volume;
    });
  }

  void startCircularTimer(int minutes) {
    if (_timer != null) _timer!.cancel();
    setState(() {
      _remainingSeconds = minutes * 60;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          RadioPlayer.play();
          _playbackState = PlaybackState.playing;
          isStopped = false;
          _remainingSeconds--;
        } else {
          timer.cancel();
          endCircularTimer();
        }
      });
    });
  }

  void endCircularTimer() {
    if (_timer != null) _timer!.cancel();
    setState(() {
      RadioPlayer.reset();
      isStopped = true;
      initRadioPlayer();
      _remainingSeconds = 0;
      _isRunning = false;
      _selectedTime = 25.0;
    });
  }

  void showSnoozeDialog(BuildContext context, Timer? _timer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int remainingSeconds =
            _isRunning ? _remainingSeconds : (_selectedTime * 60).toInt();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (!mounted) return;
              if (_isRunning && remainingSeconds > 0) {
                setState(() {
                  remainingSeconds--;
                });
              } else if (remainingSeconds <= 0) {
                timer.cancel();
              }
            });

            return AlertDialog(
              title: const Text('Timer riproduzione'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Puoi impostare un timer per interrompere automaticamente '
                      'la riproduzione. Usa lo slider per scegliere il tempo desiderato.',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: kDefaultPadding),
                      child: SleekCircularSlider(
                        min: 0,
                        max: 300,
                        initialValue: _isRunning
                            ? (_remainingSeconds / 60)
                            : _selectedTime,
                        appearance: CircularSliderAppearance(
                          customWidths: CustomSliderWidths(
                            progressBarWidth: 8,
                            trackWidth: 4,
                            handlerSize: 10,
                          ),
                          size: 150,
                          customColors: CustomSliderColors(
                            progressBarColor:
                                Theme.of(context).sliderTheme.activeTrackColor,
                            trackColor: Theme.of(context)
                                .sliderTheme
                                .inactiveTrackColor,
                            dotColor: Theme.of(context).sliderTheme.thumbColor,
                          ),
                          infoProperties: InfoProperties(
                            mainLabelStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            modifier: (double value) {
                              var varRun = _isRunning
                                  ? _remainingSeconds
                                  : value.round() * 60;
                              int hours = varRun ~/ 3600;
                              int minutes = (varRun % 3600) ~/ 60;
                              int seconds = varRun % 60;

                              return '${hours.toString().padLeft(2, '0')}:'
                                  '${minutes.toString().padLeft(2, '0')}:'
                                  '${seconds.toString().padLeft(2, '0')}';
                            },
                          ),
                        ),
                        onChange: (double value) {
                          setState(() {
                            _selectedTime = value;
                            if (_isRunning) {
                              endCircularTimer();
                              startCircularTimer(_selectedTime.toInt());
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: <Widget>[
                OutlinedButton(
                  child: const Text('Chiudi'),
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.of(context).pop();
                  },
                ),
                FilledButton.icon(
                  icon: Icon(_isRunning ? Icons.stop : Icons.nights_stay),
                  label: Text(_isRunning ? 'Ferma' : 'Avvia'),
                  onPressed: () {
                    if (_isRunning) {
                      endCircularTimer();
                    } else {
                      startCircularTimer(_selectedTime.toInt());
                    }
                    _timer?.cancel();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _playbackStateSubscription?.cancel();
    _metadataSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    Orientation orientation = mediaQuery.orientation;
    return orientation == Orientation.portrait
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    buildArt(),
                    buildInfo(),
                    buildVolumeSlider(),
                    buildButtons(),
                    buildEngage(),
                  ],
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: kDefaultPadding * 2),
                    child: SizedBox(
                      height: mediaQuery.size.height * 0.5,
                      child: buildArt(),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          buildInfo(),
                          buildVolumeSlider(),
                          buildButtons(),
                          buildEngage()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  Widget buildArt() {
    final mediaQuery = MediaQuery.of(context);
    Orientation orientation = mediaQuery.orientation;

    Image artwork = Image.asset(
      'lib/assets/logo.png',
      fit: orientation == Orientation.portrait
          ? BoxFit.fitHeight
          : BoxFit.fitWidth,
    );

    return Padding(
      padding: const EdgeInsets.only(top: kDefaultPadding),
      child: Container(
        height: mediaQuery.size.height * 0.20,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(4, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: artwork,
        ),
      ),
    );
  }

  Widget buildInfo() {
    return Padding(
      padding: const EdgeInsets.only(
        top: kDefaultPadding,
        right: kDefaultPadding,
        left: kDefaultPadding,
      ),
      child: Column(
        children: <Widget>[
          Text(
            textAlign: TextAlign.center,
            _metadata?.title ?? '',
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            textAlign: TextAlign.center,
            _metadata?.artist ?? '',
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVolumeSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding * 2),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.volume_off),
          Expanded(
            child: Slider(
              value: _currentVolume,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: (_currentVolume * 100).round().toString(),
              onChanged: (double value) {
                setVolume(value);
              },
            ),
          ),
          const Icon(Icons.volume_up),
        ],
      ),
    );
  }

  Widget buildButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton.filled(
            icon: const Icon(Icons.stop),
            iconSize: 32.0,
            onPressed: () {
              RadioPlayer.reset();
              isStopped = true;
              _remainingSeconds = 0;
              _isRunning = false;
              _selectedTime = 25.0;
              initRadioPlayer();
            },
          ),
          IconButton.filled(
            icon: Icon(
              _playbackState == PlaybackState.playing
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
            ),
            iconSize: 64.0,
            onPressed: () {
              _playbackState == PlaybackState.playing
                  ? RadioPlayer.pause()
                  : RadioPlayer.play();
              isStopped = false;
              _remainingSeconds = 0;
              _isRunning = false;
              _selectedTime = 25.0;
            },
          ),
          IconButton.filled(
            icon: const Icon(Icons.snooze),
            iconSize: 32.0,
            onPressed: () {
              showSnoozeDialog(context, _timer);
            },
          ),
        ],
      ),
    );
  }

  Widget buildEngage() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                themeProvider.isDarkMode ? kPrimaryLightColor : kPrimaryColor,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        child: Column(
          children: [
            Link(
              uri: Uri.parse('tel:+390115695213'),
              target: LinkTarget.blank,
              builder: (context, followLink) {
                return InkWell(
                  onTap: followLink,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: const ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.call),
                    ),
                    title: Text(
                      'Chiamaci in diretta',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('(+39) 011 569 52 13'),
                  ),
                );
              },
            ),
            Link(
              uri: Uri.parse('https://wa.me/390115695213'),
              target: LinkTarget.blank,
              builder: (context, followLink) {
                return InkWell(
                  onTap: followLink,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: const ListTile(
                    leading: CircleAvatar(
                      child: FaIcon(FontAwesomeIcons.whatsapp),
                    ),
                    title: Text(
                      'Scrivici o registra un vocale',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Sarà una gioia per noi ascoltarti o darti conforto!',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
