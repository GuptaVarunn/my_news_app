import 'package:flutter/material.dart';
import '../utils/url_launcher.dart';
import 'dart:math';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart';
import '../services/saved_articles_service.dart';  // Add this import

class NewsArticle {
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final DateTime publishedAt;
  final String source;
  final String sourceLogo;

  NewsArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.publishedAt,
    this.source = '',  // Default empty string
    this.sourceLogo = '',  // Default empty string
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? '',
      link: json['url'] ?? '',
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
      source: json['source']?['name'] ?? '',
      sourceLogo: '', // GNews API doesn't provide source logos
    );
  }
}
class NewsList extends StatelessWidget {
  final List<NewsArticle> articles;

  const NewsList({super.key, required this.articles});

  void _shareArticle(NewsArticle article) {
    Share.share(
      '${article.title}\n\nRead more at: ${article.link}',
      subject: article.title,
    );
  }

  void _handleProtectedAction(BuildContext context, Function action) {
    if (FirebaseAuth.instance.currentUser == null) {
      // User not logged in, show login prompt
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sign in Required'),
          content: Text('Please sign in to use this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      );
    } else {
      // User is logged in, perform the action
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        NewsArticle article = articles[index];

        return Card(
          elevation: 4,
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: article.imageUrl.isNotEmpty
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          article.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallbackImage(article);
                          },
                        ),
                      )
                    : _buildFallbackImage(article),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            article.sourceLogo,
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.newspaper, size: 24);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          article.source,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Spacer(),
                        Text(
                          _formatDate(article.publishedAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => launchURL(article.link),
                          icon: Icon(Icons.read_more),
                          label: Text('Read More'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              // Use it for share and save buttons
                              icon: Icon(Icons.share),
                              color: Colors.blueAccent,
                              onPressed: () => _handleProtectedAction(context, () => _shareArticle(article)),
                            ),
                            // In the NewsList class, update the bookmark IconButton:
                            IconButton(
                              icon: Icon(Icons.bookmark_border),
                              color: Colors.blueAccent,
                              onPressed: () => _handleProtectedAction(
                                context,
                                () async {
                                  await SavedArticlesService().saveArticle(article);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Article saved successfully')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildFallbackImage(NewsArticle article) {
  final random = Random();
  final fallbackImages = [
    'lib/assets/breaking_news_1.jpeg',
    'lib/assets/breaking_news_2.jpeg',
    'lib/assets/breaking_news_3.jpeg',
    'lib/assets/breaking_news_4.jpeg',
    'lib/assets/breaking_news_5.jpeg',
    'lib/assets/breaking_news_6.jpeg',
  ];
  
  final randomImage = fallbackImages[random.nextInt(fallbackImages.length)];
  
  return Container(
    height: 200,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.asset(
        randomImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading asset image: $error');  // Debug print
          return Container(
            color: Colors.grey[200],
            child: Icon(Icons.newspaper, size: 80, color: Colors.grey[400]),
          );
        },
      ),
    ),
  );
}

String _formatDate(DateTime publishedAt) {
  return '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
}
