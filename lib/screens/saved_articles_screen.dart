import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/saved_articles_service.dart';
import '../models/news_articles.dart';
import '../widgets/news_card.dart';  // Add this import

class SavedArticlesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Articles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: SavedArticlesService().getSavedArticles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading saved articles'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No saved articles'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return NewsCard(
                article: NewsArticle(
                  title: data['title'],
                  description: data['description'],
                  imageUrl: data['imageUrl'],
                  link: data['sourceUrl'],
                  publishedAt: (data['publishedAt'] as Timestamp).toDate(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}