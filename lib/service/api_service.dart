import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  static Future<List<Article>> fetchList(String type,
      {int limit = 10, int offset = 0}) async {
    final url =
        Uri.parse('$_baseUrl/$type/?limit=$limit&offset=$offset');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((e) => Article.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}');
    }
  }

  static Future<Article> fetchDetail(String type, int id) async {
    final url = Uri.parse('$_baseUrl/$type/$id/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Article.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail: ${response.statusCode}');
    }
  }
}