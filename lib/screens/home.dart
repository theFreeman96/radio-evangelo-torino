import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../utilities/constants.dart';
import '../utilities/theme_provider.dart';
import 'home_bottom.dart';
import 'info_page.dart';
import 'news_page.dart';
import 'player_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final List<Widget> pageBodies = [
    const PlayerPage(),
    const NewsPage(),
    const InfoPage(),
  ];

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then((token) {
      print("Token del dispositivo: $token");
    });
    FirebaseMessaging.instance.subscribeToTopic('user');
    print("Iscritto al topic: 'user'");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Messaggio ricevuto: ${message.notification?.title}");
      showLocalNotification(message.data);
    });
  }

  Future<void> showLocalNotification(Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'avvisi_radio_evangelo_torino',
      'avvisi_radio_evangelo_torino',
      channelDescription: 'avvisi_radio_evangelo_torino',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      data['Title'],
      data['Body'],
      platformChannelSpecifics,
      payload: data.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              'Radio Evangelo Torino',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding / 2),
                child: Switch(
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  value: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: currentIndex,
            children: pageBodies,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          bottomNavigationBar: HomeBottomBar(
            currentIndex: currentIndex,
            onTabTapped: onTabTapped,
          ),
        );
      },
    );
  }
}
