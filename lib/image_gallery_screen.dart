import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'pixabay_service.dart'; // Подключаем наш API сервис

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final PixabayService _pixabayService = PixabayService();
  final ScrollController _scrollController = ScrollController();
  final List<ImageData> _images = [];
  int _currentPage = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchImages();
      }
    });
  }

  Future<void> _fetchImages() async {
    setState(() {
      _isLoading = true;
    });
    final images = await _pixabayService.fetchImages(_currentPage);
    setState(() {
      _images.addAll(images);
      _currentPage++;
      _isLoading = false;
    });
  }

  String _formatViewsCount(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M 👀';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K 👀';
    } else {
      return '$views 👀';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery by Farrukh ® 2024'),
      ),
      body: _images.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _calculateCrossAxisCount(context),
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      final image = _images[index];
                      return GridTile(
                        footer: GridTileBar(
                          backgroundColor: Colors.black54,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${image.likes} ❤️'),
                              Text(_formatViewsCount(image.views)),
                            ],
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: image.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width ~/ 150).clamp(2, 5); // Минимум 2 колонки, максимум 5
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
