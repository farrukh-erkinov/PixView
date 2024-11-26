import 'dart:convert';
import 'package:http/http.dart' as http;

class PixabayService {
  final String apiKey = 'xxx';

  Future<List<ImageData>> fetchImages({int page = 1, String query = ''}) async {
    final url =
        'https://pixabay.com/api/?key=$apiKey&image_type=photo&per_page=20&page=$page&q=$query&safesearch=true';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List images = data['hits'];

      return images.map((json) => ImageData.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки данных с Pixabay');
    }
  }
}

class ImageData {
  final String url;
  final String author;
  final String tags;
  final int likes;
  final int views;

  ImageData({
    required this.url,
    required this.author,
    required this.tags,
    required this.likes,
    required this.views,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      url: json['webformatURL'],
      author: json['user'],
      tags: json['tags'],
      likes: json['likes'],
      views: json['views'],
    );
  }
}
