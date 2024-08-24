import 'package:url_launcher/url_launcher.dart';

void openPrivacyPolicy({bool newWindow = true}) {
  final link = Uri.parse(
      "https://firebasestorage.googleapis.com/v0/b/gptthing-a25d7.appspot.com/o/public%2FSilver%20Pangolin%20Privacy%20Policy.pdf?alt=media");
  launchUrl(link, webOnlyWindowName: newWindow ? "_blank" : "_self");
}

void openTOS({bool newWindow = true}) {
  final link = Uri.parse(
      "https://firebasestorage.googleapis.com/v0/b/gptthing-a25d7.appspot.com/o/public%2FChatKeyPT%20Terms%20of%20Service.pdf?alt=media");
  launchUrl(link, webOnlyWindowName: newWindow ? "_blank" : "_self");
}
