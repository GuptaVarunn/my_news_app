import 'package:flutter/material.dart';
import '../utils/url_launcher.dart';

class NewsArticle {
  final String title;
  final String source;
  final String link;
  final String imageUrl;
  final String description;
  final String publishedAt;

  NewsArticle({
    required this.title,
    required this.source,
    required this.link,
    required this.imageUrl,
    required this.description,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      source: json['source']?['name'] ?? 'Unknown Source',
      link: json['url'] ?? '',
      imageUrl: json['image'] ?? '',  // GNews uses 'image' instead of 'urlToImage'
      description: json['description'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}
class NewsList extends StatelessWidget {
  final List<NewsArticle> articles;

  const NewsList({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        NewsArticle article = articles[index];

        return Card(
          elevation: 4,
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              article.imageUrl.isNotEmpty
                  ? Image.network(
                      article.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(height: 150, color: Colors.grey), // Handle missing images
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Source: ${article.source}",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => launchURL(article.link),
                          child: Text('Read More'),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.bookmark_border,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            // Handle save for later logic (redirect to login if not signed in)
                          },
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
