import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/home.dart';
import 'utilities/theme_provider.dart';
import 'utilities/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RadioEvangeloTorino());
}

class RadioEvangeloTorino extends StatefulWidget {
  const RadioEvangeloTorino({super.key});

  @override
  RadioEvangeloTorinoState createState() => RadioEvangeloTorinoState();
}

class RadioEvangeloTorinoState extends State<RadioEvangeloTorino> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, ThemeProvider themeProvider, child) => MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: const Home(),
        ),
      ),
    );
  }
}
