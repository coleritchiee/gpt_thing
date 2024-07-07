import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatImage extends StatelessWidget {
  const ChatImage({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(color: Colors.grey[900]!),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_rounded, color: Colors.grey[700]),
                    const Text(
                      "Loading image...",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: downloadProgress.progress,
                      ),
                    ),
                  ],
                );
              },
              errorWidget: (context, url, error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported_rounded, color: Colors.grey[700]),
                  const Text(
                    "Something went wrong.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              fadeOutDuration: Duration.zero,
            ),
          ),
        ),
      ),
    );
  }
}
