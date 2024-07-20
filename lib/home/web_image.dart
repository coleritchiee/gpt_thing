import 'dart:math';
import 'package:flutter/material.dart';

class WebImage extends StatelessWidget {
  const WebImage({
    super.key,
    required this.imageUrl,
    required this.imgLoaded,
    required this.altText,
  });

  final String imageUrl;
  final ValueNotifier<bool> imgLoaded;
  final String? altText;


  @override
  Widget build(BuildContext context) {
    // https://github.com/flutter/flutter/issues/105823#issuecomment-1152895191
    // have to use this because loadingProgress can be null even when the image
    // is loading
    bool isLoaded = false;
    final sideLength =
        (min(MediaQuery.of(context).size.width, 768) * 0.6).round();
    return Image.network(
      imageUrl,
      cacheWidth: sideLength,
      cacheHeight: sideLength,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        isLoaded = frame != null;
        return child;
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (isLoaded && loadingProgress == null) {
          if (!imgLoaded.value) {
            Future.delayed(Duration.zero, () {
              imgLoaded.value = true;
            });
          }
          return child;
        } else {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
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
                  height: 6,
                ),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    value: loadingProgress != null &&
                            loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              ],
            ),
          );
        }
      },
      errorBuilder: (context, error, stackTrace) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_rounded, color: Colors.grey[700]),
            const Text(
              "Image not found.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (altText != null)
              Text(
                "Alt: ${altText!}",
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
