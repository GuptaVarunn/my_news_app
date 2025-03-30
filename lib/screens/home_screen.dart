import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/news_articles.dart';
import '../utils/url_launcher.dart';
import '../utils/shared_prefs.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  String selectedCategory = 'home';
  String? userEmail;
  List<NewsArticle> articles = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchNews();
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

    final apiKey = 'b883008f0ad94021b4c6d4c651752a69'; // Replace with your actual API key
    var url = 'https://newsapi.org/v2/top-headlines?country=in&category=$selectedCategory&apiKey=$apiKey';


    switch (selectedCategory) {
      case 'Home':
        url = 'https://newsapi.org/v2/everything?q=india&apiKey=$apiKey';
        break;
      case 'India':
        url = 'https://newsapi.org/v2/everything?q=india&language=en&sortBy=publishedAt&apiKey=$apiKey';
        break;
      case 'Local':
        url = 'https://newsapi.org/v2/everything?q=mumbai&sortBy=publishedAt&apiKey=$apiKey';
        break;
      case 'Sports':
        url = 'https://newsapi.org/v2/top-headlines?category=sports&apiKey=$apiKey';
        break;
      case 'Technology':
        url = 'https://newsapi.org/v2/top-headlines?category=technology&apiKey=$apiKey';
        break;
      case 'Health':
        url = 'https://newsapi.org/v2/everything?q=health&sortBy=publishedAt&apiKey=$apiKey';
        break;
      case 'Entertainment':
        url = 'https://newsapi.org/v2/everything?q=entertainment&sortBy=publishedAt&apiKey=$apiKey';
        break;

      
      default:
        url = 'https://newsapi.org/v2/everything?q=india&apiKey=$apiKey';
    }


    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            articles = (data['articles'] as List)
                .map((item) => NewsArticle.fromJson(item))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load news');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('News App'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshNews,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.person),
            onSelected: (value) {
              if (value == 'Logout') {
                _logout();
              } else {
                _navigateToAuth();
              }
            },
            itemBuilder: (context) => [
              if (userEmail != null)
                PopupMenuItem(value: 'Logout', child: Text('Logout')),
              if (userEmail == null)
                PopupMenuItem(value: 'Login', child: Text('Login / Sign Up')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
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
                          : ListView.builder(
                              itemCount: articles.length,
                              itemBuilder: (context, index) {
                                NewsArticle article = articles[index];
                                return Card(
                                  elevation: 4,
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (article.imageUrl.isNotEmpty)
                                        Image.network(
                                          article.imageUrl,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 150,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.image_not_supported),
                                            );
                                          },
                                        ),
                                      ListTile(
                                        title: Text(
                                          article.title,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 8.0),
                                              child: Text("Source: ${article.source}"),
                                            ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.bookmark_border, color: Colors.blueAccent),
                                          onPressed: () {
                                            _navigateToAuth();
                                          },
                                        ),
                                        onTap: () {
                                          launchURL(article.link);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}