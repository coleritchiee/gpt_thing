import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gal/gal.dart';
import 'package:gpt_thing/home/compact_icon_button.dart';
import 'package:gpt_thing/home/mobile_image.dart';
import 'package:gpt_thing/home/web_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class ChatImage extends StatelessWidget {
  ChatImage({
    super.key,
    required this.imageUrl,
    this.altText,
  });

  final String imageUrl;
  final String? altText;

  final ValueNotifier<bool> imgLoaded = ValueNotifier(false);

  void checkInCache() async {
    final FileInfo? file =
        await DefaultCacheManager().getFileFromCache(imageUrl);
    if (file != null) {
      imgLoaded.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == "Generating...") {
      return FractionallySizedBox(
        widthFactor: 0.6,
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[900]!),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_rounded, color: Colors.grey[700]),
                  const Text(
                    "Generating...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  const SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey[900]!),
                  child: kIsWeb
                      ? WebImage(
                          imageUrl: imageUrl,
                          imgLoaded: imgLoaded,
                          altText: altText)
                      : MobileImage(
                          imageUrl: imageUrl,
                          imgLoaded: imgLoaded,
                          altText: altText),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: ListenableBuilder(
                listenable: imgLoaded,
                builder: (context, snapshot) {
                  if (imgLoaded.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CompactIconButton(
                            icon: const Icon(Icons.file_download_rounded),
                            tooltip: "Save image (full quality)",
                            showLoading: true,
                            onPressed: () => saveImage(imageUrl, context),
                          ),
                          if (!kIsWeb)
                            CompactIconButton(
                              icon: Platform.isAndroid
                                  ? const Icon(Icons.share_rounded)
                                  : const Icon(Icons.ios_share_rounded),
                              showLoading: true,
                              onPressed: () => shareImage(imageUrl),
                            ),
                        ],
                      ),
                    );
                  } else {
                    checkInCache();
                    return const SizedBox.shrink();
                  }
                }),
          ),
        ],
      );
    }
  }
}

Future<bool> saveImage(String url, BuildContext context) async {
  if (kIsWeb) {
    html.window.open(url, "image");
  } else {
    final file = await DefaultCacheManager().getSingleFile(url);
    try {
      await Gal.putImageBytes(file.readAsBytesSync());
    } catch (e) {
      String msg = "Something went wrong";
      if (e is GalException) {
        switch (e.type) {
          case GalExceptionType.accessDenied:
            if (context.mounted) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Access Denied"),
                      content: const Text(
                          "To save images, you need to enable the permission for this app in Settings."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  });
            }
            return false;
          case GalExceptionType.notEnoughSpace:
            msg = "Insufficient space";
            break;
          case GalExceptionType.notSupportedFormat:
            msg = "File type not supported";
          case GalExceptionType.unexpected:
            // default
            break;
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
          ),
        );
      }
      return false;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image saved"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  return true;
}

Future<bool> shareImage(String url) async {
  if (!kIsWeb) {
    final file = await DefaultCacheManager().getSingleFile(url);
    final result = await Share.shareXFiles(
        [XFile.fromData(file.readAsBytesSync(), mimeType: "png")]);
    return result.status == ShareResultStatus.success;
  }
  return false;
}
