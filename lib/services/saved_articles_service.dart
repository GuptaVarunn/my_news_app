import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/news_articles.dart';

class SavedArticlesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveArticle(NewsArticle article) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final articleId = article.link.hashCode.toString();
    final docRef = _firestore
        .collection('saved_articles')
        .doc(user.uid)
        .collection('articles')
        .doc(articleId);

    await docRef.set({
      'userId': user.uid,
      'articleId': articleId,
      'title': article.title,
      'description': article.description,
      'imageUrl': article.imageUrl,
      'sourceUrl': article.link,
      'publishedAt': article.publishedAt,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getSavedArticles() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore
        .collection('saved_articles')
        .doc(user.uid)
        .collection('articles')
        .orderBy('savedAt', descending: true)
        .snapshots();
  }
}