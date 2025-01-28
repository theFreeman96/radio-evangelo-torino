import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utilities/constants.dart';
import '../utilities/theme_provider.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  final int currentIndex;
  final Function(int) onTabTapped;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return NavigationBar(
      elevation: 0.0,
      selectedIndex: currentIndex,
      onDestinationSelected: onTabTapped,
      indicatorColor:
          themeProvider.isDarkMode ? kBlack : kWhite.withValues(alpha: 0.3),
      backgroundColor: themeProvider.isDarkMode ? kGrey : kPrimaryColor,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.radio_outlined),
          selectedIcon: Icon(Icons.radio),
          label: 'Radio',
          tooltip: 'Radio',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined),
          selectedIcon: Icon(Icons.event),
          label: 'Avvisi',
          tooltip: 'Avvisi',
        ),
        NavigationDestination(
          icon: Icon(Icons.info_outline),
          selectedIcon: Icon(Icons.info),
          label: 'Info',
          tooltip: 'Info',
        ),
      ],
    );
  }
}
