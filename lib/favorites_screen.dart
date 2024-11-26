import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'pixabay_service.dart';

class FavoritesScreen extends StatelessWidget {
  final List<ImageData> favoriteImages;

  const FavoritesScreen({super.key, required this.favoriteImages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранные изображения'),
      ),
      body: favoriteImages.isEmpty
          ? const Center(
              child: Text(
                'Нет избранных изображений',
                style: TextStyle(fontSize: 18),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1,
              ),
              itemCount: favoriteImages.length,
              itemBuilder: (context, index) {
                final image = favoriteImages[index];
                return GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black54,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${image.likes} ❤️'),
                        Text('${image.views} 👀'),
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
    );
  }
}
