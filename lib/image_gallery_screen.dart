import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixview/favorites_screen.dart';
import 'pixabay_service.dart';
import 'image_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final PixabayService _pixabayService = PixabayService();
  final ScrollController _scrollController = ScrollController();
  final List<ImageData> _images = [];
  final List<ImageData> _favorites = [];
  int _currentPage = 1;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
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
    final images = await _pixabayService.fetchImages(
        page: _currentPage, query: _searchQuery);
    setState(() {
      _images.addAll(images);
      _currentPage++;
      _isLoading = false;
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favorites.addAll(
          savedFavorites.map((json) => ImageData.fromJson(jsonDecode(json))));
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = _favorites.map((image) => jsonEncode(image)).toList();
    await prefs.setStringList('favorites', favoritesJson);
  }

  void _toggleFavorite(ImageData image) {
    setState(() {
      if (_favorites.contains(image)) {
        _favorites.remove(image);
      } else {
        _favorites.add(image);
      }
      _saveFavorites();
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
        title: const Text('PixView by Farrukh E.'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      FavoritesScreen(favoriteImages: _favorites),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск...',
                border: OutlineInputBorder(),
                filled: true,
              ),
              onSubmitted: (query) {
                setState(() {
                  _searchQuery = query;
                  _images.clear();
                  _currentPage = 1;
                });
                _fetchImages();
              },
            ),
          ),
        ),
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
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ImageDetailScreen(image: image),
                          ),
                        ),
                        child: GridTile(
                          footer: GridTileBar(
                            backgroundColor: Colors.black54,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${image.likes} ❤️'),
                                Text(_formatViewsCount(image.views)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                _favorites.contains(image)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () => _toggleFavorite(image),
                            ),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: image.url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
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
    return (width ~/ 150).clamp(2, 5);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
