// ignore_for_file: unused_import, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/news_articles.dart';
import '../utils/url_launcher.dart';
import '../utils/shared_prefs.dart';
import '../config/api_config.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart'; 

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  String selectedCategory = 'Home';
  String? userEmail;
  List<NewsArticle> articles = [];
  bool isLoading = true;
  String? error;
  bool isDarkMode = false;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  List<NewsArticle> filteredArticles = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchNews();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final darkMode = await SharedPrefsHelper.getDarkMode();
    setState(() {
      isDarkMode = darkMode;
    });
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      SharedPrefsHelper.setDarkMode(isDarkMode);
    });
  }

  void _filterArticles() {
    if (searchQuery.isEmpty) {
      filteredArticles = articles;
    } else {
      filteredArticles = articles
          .where((article) =>
              article.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              article.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  // Add this method for sharing
  void _shareArticle(NewsArticle article) {
    Share.share(
      '${article.title}\n\nRead more at: ${article.link}',
      subject: article.title,
    );
  }

  void _loadUser() async {
    String? email = await SharedPrefsHelper.getUserEmail();
    setState(() {
      userEmail = email;
    });
  }

  void _logout() async {
    await SharedPrefsHelper.clearUserData();
    setState(() {
      userEmail = null;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _navigateToAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => userEmail == null ? SignupPage() : LoginPage(),
      ),
    ).then((_) => _loadUser());
  }

  Future<void> _fetchNews() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final apiKey = dotenv.env['GNEWS_API_KEY'] ?? '';
    String url;

    switch (selectedCategory) {
      case 'Home':
        url = '${ApiConfig.baseUrl}/search?q=news&lang=en&country=in&apikey=$apiKey';
        break;
      case 'India':
        url = '${ApiConfig.baseUrl}/top-headlines?lang=en&country=in&apikey=$apiKey';
        break;
      case 'Local':
        url = '${ApiConfig.baseUrl}/search?q=(mumbai OR maharashtra)&lang=en,mr&country=in&apikey=$apiKey';
        break;
      case 'Sports':
        url = '${ApiConfig.baseUrl}/top-headlines?category=sports&lang=en&country=in&apikey=$apiKey';
        break;
      case 'Technology':
        url = '${ApiConfig.baseUrl}/top-headlines?category=technology&lang=en&country=in&apikey=$apiKey';
        break;
      case 'Health':
        url = '${ApiConfig.baseUrl}/top-headlines?category=health&lang=en&country=in&apikey=$apiKey';
        break;
      case 'Entertainment':
        url = '${ApiConfig.baseUrl}/top-headlines?category=entertainment&lang=en&country=in&apikey=$apiKey';
        break;
      default:
        url = '${ApiConfig.baseUrl}/top-headlines?lang=en&country=in&apikey=$apiKey';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['articles'] != null) {
          setState(() {
            articles = (data['articles'] as List)
                .map((item) => NewsArticle.fromJson(item))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('No articles found');
        }
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshNews() async {
    setState(() {
      articles = [];
    });
    await _fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('News App'),
          backgroundColor: Colors.blueAccent,  // Set the color to match login screen
          actions: [
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return PopupMenuButton(
                    icon: Icon(Icons.person),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.account_circle),
                          title: Text(snapshot.data?.email ?? ''),
                        ),
                        enabled: false,
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Logout'),
                        ),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logged out successfully')),
                          );
                        },
                      ),
                    ],
                  );
                }
                return TextButton(
                  child: Text('Sign In', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search news...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    _filterArticles();
                  });
                },
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['Home', 'India', 'Local', 'Sports', 'Technology', 'Health', 'Entertainment']
                    .map((category) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCategory == category
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedCategory = category;
                        });
                        _fetchNews();
                      },
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshNews,
                child: error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(error!),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchNews,
                              child: Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : isLoading
                        ? Center(child: CircularProgressIndicator())
                        : articles.isEmpty
                            ? Center(child: Text('No news available'))
                            : NewsList(articles: articles),  // Use the NewsList widget
            ),
          ),
        ],
      ),
    ),
  );
  }
}