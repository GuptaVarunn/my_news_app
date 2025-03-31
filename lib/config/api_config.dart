import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get apiKey => dotenv.env['GNEWS_API_KEY'] ?? '';
  static const String baseUrl = 'https://gnews.io/api/v4';
  
  // API Endpoints
  static const String topHeadlines = '/top-headlines';
  static const String search = '/search';
  
  // Country and Language settings
  static const String country = 'in';
  static const String language = 'en';
  
  // Category endpoints
  static Map<String, String> getCategoryUrls() {
    return {
      'Home': '$baseUrl/search?q=india&lang=$language&country=$country&max=10&apikey=$apiKey',
      'India': '$baseUrl/search?q=india news&in=title&lang=$language&country=$country&max=10&apikey=$apiKey',
      'Local': '$baseUrl/search?q=mumbai&in=title&lang=$language&country=$country&max=10&apikey=$apiKey',
      'Sports': '$baseUrl/search?q=sports&in=title&lang=$language&country=$country&max=10&apikey=$apiKey',
      'Technology': '$baseUrl/search?q=technology&in=title&lang=$language&country=$country&max=10&apikey=$apiKey',
      'Health': '$baseUrl/search?q=health&in=title&lang=$language&country=$country&max=10&apikey=$apiKey',
      'Entertainment': '$baseUrl/search?q=entertainment&in=title&lang=$language&country=$country&max=10&apikey=$apiKey',
    };
  }
}