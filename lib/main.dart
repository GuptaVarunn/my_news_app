import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await dotenv.load();
    runApp(MyApp());
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
        cardColor: _isDarkMode ? Colors.grey[850] : Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.blue,
          elevation: 2,
        ),
      ),
      home: NewsHomePage(
        isDarkMode: _isDarkMode,
        onThemeToggle: toggleTheme,
      ),
    );
  }
}
