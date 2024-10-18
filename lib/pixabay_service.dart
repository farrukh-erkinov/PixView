import 'dart:convert';
import 'package:http/http.dart' as http;

class PixabayService {
  final String apiKey =
      '46442938-2e3a0c3011fc7b097e6529518'; // Вставьте свой API ключ

  Future<List<ImageData>> fetchImages(int page) async {
    final url =
        'https://pixabay.com/api/?key=$apiKey&image_type=photo&per_page=20&page=$page';
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
  final int likes;
  final int views;

  ImageData({required this.url, required this.likes, required this.views});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      url: json['webformatURL'],
      likes: json['likes'],
      views: json['views'],
    );
  }
}
