import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/article.dart';

class NewsService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://newsapi.org/v2'));
  final String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  static const List<String> categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology',
  ];

  Future<List<Article>> fetchBusinessNews() async {
    try {
      final response = await _dio.get(
        '/top-headlines',
        queryParameters: {
          'country': 'us',
          'category': 'business',
          'apiKey': apiKey,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> articlesJson = response.data['articles'];
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }



  Future<List<Article>> fetchTopHeadlines({
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/top-headlines',
        queryParameters: {
          'country': 'us',
          if (category != null && categories.contains(category)) 'category': category,
          'page': page,
          'pageSize': pageSize,
          'apiKey': apiKey,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> articlesJson = response.data['articles'];
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

}