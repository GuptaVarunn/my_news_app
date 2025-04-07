import 'package:flutter/material.dart';
import 'package:my_news_app/screens/login_screen.dart';
import 'package:my_news_app/screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await dotenv.load();
    
    // Load saved theme preference
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    
    runApp(MyApp(initialDarkMode: isDarkMode));
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;
  
  const MyApp({super.key, this.initialDarkMode = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
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
          backgroundColor: Colors.blueAccent,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: _isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => NewsHomePage(
          isDarkMode: _isDarkMode,
          onThemeToggle: toggleTheme,
        ),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
      },
    );
  }
}
