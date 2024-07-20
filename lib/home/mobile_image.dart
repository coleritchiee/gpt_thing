import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MobileImage extends StatelessWidget {
  const MobileImage({
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
    return CachedNetworkImage(
      imageUrl: imageUrl,
      memCacheWidth: (min(MediaQuery.of(context).size.width, 768) * 0.6).round(),
      // imageBuilder: (context, imageProvider) {
      //   if (!imgLoaded.value) {
      //     Future.delayed(Duration.zero, () {
      //       imgLoaded.value = true;
      //     });
      //   }
      //   return Image(image: imageProvider);
      // },
      progressIndicatorBuilder: (context, url, downloadProgress) {
        if (downloadProgress.progress == 1 && !imgLoaded.value) {
          Future.delayed(Duration.zero, () {
            imgLoaded.value = true;
          });
        }
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
                  value: downloadProgress.progress,
                ),
              ),
            ],
          ),
        );
      },
      errorWidget: (context, url, error) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_rounded,
                color: Colors.grey[700]),
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
      fadeOutDuration: Duration.zero,
    );
  }
}
