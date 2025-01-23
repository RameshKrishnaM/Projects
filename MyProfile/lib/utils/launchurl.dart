import 'package:url_launcher/url_launcher.dart';

launchUrlFunction(String blogLink) async {
  final url = Uri.parse(blogLink);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}
