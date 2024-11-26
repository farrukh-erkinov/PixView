import 'package:flutter/material.dart';
import 'pixabay_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageDetailScreen extends StatelessWidget {
  final ImageData image;

  const ImageDetailScreen({super.key, required this.image});

  Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      return false;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }
    return false;
  }

  Future<void> _downloadImage(BuildContext context, String imageUrl) async {
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Разрешение на доступ к хранилищу не предоставлено.')),
      );
      return;
    }

    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Не удалось найти директорию для сохранения.')),
        );
        return;
      }

      final fileName = imageUrl.split('/').last;
      final filePath = '${directory.path}/$fileName';

      final dio = Dio();
      final response = await dio.download(imageUrl, filePath);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Изображение успешно сохранено: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при скачивании изображения.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали изображения'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.network(image.url, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Автор: ${image.author}',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('Теги: ${image.tags}',
                    style: Theme.of(context).textTheme.bodyMedium),
                Text('Лайки: ${image.likes} ❤️'),
                Text('Просмотры: ${image.views} 👀'),
                ElevatedButton(
                  onPressed: () {
                    _downloadImage(context, image.url);
                  },
                  child: const Text('Скачать'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
