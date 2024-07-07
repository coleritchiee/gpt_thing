import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:gpt_thing/home/compact_icon_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class ChatImage extends StatelessWidget {
  const ChatImage({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FractionallySizedBox(
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CompactIconButton(
                icon: const Icon(Icons.file_download_rounded),
                tooltip: "Save image",
                onPressed: () {
                  saveImage(imageUrl);
                },
              ),
              if (!kIsWeb)
                CompactIconButton(
                  icon: Platform.isAndroid
                      ? const Icon(Icons.share_rounded)
                      : const Icon(Icons.ios_share_rounded),
                  onPressed: () {
                    shareImage(imageUrl);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

void saveImage(String url) async {
  if (kIsWeb) {
    html.AnchorElement anchor = html.AnchorElement(href: url);
    anchor.download = url;
    anchor.click();
    anchor.remove();
  } else {
    final imagePath = '${Directory.systemTemp.path}/image.png';
    await Dio().download(url, imagePath);
    await Gal.putImage(imagePath);
  }
}

void shareImage(String url) async {
  if (!kIsWeb) {
    final imagePath = '${Directory.systemTemp.path}/image.png';
    await Dio().download(url, imagePath);
    Share.shareXFiles([XFile(imagePath)]);
  }
}
