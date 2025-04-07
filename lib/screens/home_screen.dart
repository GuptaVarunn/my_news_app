// ignore_for_file: unused_import, unused_element

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_news_app/utils/snackbar_helper.dart';
import 'dart:convert';
import '../models/news_articles.dart';
import '../utils/url_launcher.dart';
import '../utils/shared_prefs.dart';
import '../config/api_config.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart'; 

// Add this import at the top with other imports
import 'saved_articles_screen.dart';

class NewsHomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const NewsHomePage({
    Key? key,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  String selectedCategory = 'Home';
  List<NewsArticle> articles = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    
    showCustomSnackBar(
      context,
      '👋 See you soon! Successfully logged out',
      isSuccess: true,
    );
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  // Update the _fetchNews method for local news
  Future<void> _fetchNews() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final apiKey = dotenv.env['GNEWS_API_KEY'];
      if (apiKey == null) {
        throw Exception('API key not found');
      }

      String category = selectedCategory.toLowerCase();
      String lang = 'en';
      String url;
      
      if (category == 'local') {
        // Special handling for local news (Mumbai/Maharashtra)
        url = 'https://gnews.io/api/v4/search?'
          'q=(Mumbai OR Maharashtra)'
          '&lang=$lang'
          '&country=in'
          '&apikey=$apiKey'
          '&max=20';
      } else {
        final categoryMap = {
          'home': 'general',
          'india': 'nation',
          'sports': 'sports',
          'technology': 'technology',
          'health': 'health',
          'entertainment': 'entertainment'
        };

        final mappedCategory = categoryMap[category] ?? 'general';
        url = 'https://gnews.io/api/v4/top-headlines?'
          'category=$mappedCategory'
          '&lang=$lang'
          '&country=in'
          '&apikey=$apiKey'
          '&max=20';
      }

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articlesData = data['articles'] ?? [];
        
        setState(() {
          articles = articlesData.map((article) {
            // Add fallback image logic
            if (article['image'] == null || article['image'].toString().isEmpty) {
              final random = Random().nextInt(6) + 1;
              article['image'] = 'assets/breaking_news_$random.jpeg';
            }
            return NewsArticle.fromJson(article);
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Unable to load news. Please try again later.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Connection error. Please check your internet connection.';
        isLoading = false;
        articles = [];
      });
    }
  }

  Future<void> _refreshNews() async {
    return _fetchNews();
  }

  // Update the AppBar in build method
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'News App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: widget.onThemeToggle,
          ),
          PopupMenuButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            itemBuilder: (context) => [
              if (user != null) ...[
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.bookmark),
                    title: Text('Saved Articles'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SavedArticlesScreen()),
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () => _handleLogout(context),
                ),
              ] else
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.login),
                    title: Text('Sign In'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(8),
            child: SingleChildScrollView(
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
                            ? (widget.isDarkMode ? Colors.blue[700] : Colors.blue)
                            : (widget.isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                        foregroundColor: selectedCategory == category
                            ? Colors.white
                            : (widget.isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedCategory = category;
                        });
                        _fetchNews();
                      },
                      child: Text(category.toUpperCase()),
                    ),
                  );
                }).toList(),
              ),
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
                          Text(
                            error!,
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
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
                          ? Center(
                              child: Text(
                                'No news available',
                                style: TextStyle(
                                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            )
                          : NewsList(articles: articles),
            ),
          ),
        ],
      ),
    );
  }
}