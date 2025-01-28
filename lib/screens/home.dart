import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
