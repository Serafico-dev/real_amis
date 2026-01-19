import 'package:url_launcher/url_launcher.dart';

Future<void> openSupportContact({
  String email = 'federico.mereu@outlook.it',
  String subject = 'Supporto app Real Amis',
  String body = '',
}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: {'subject': subject, 'body': body},
  );

  if (!await launchUrl(uri)) {
    // fallback: prova a copiare l'indirizzo o mostrare un snackbar (implementa showSnackBar)
    throw Exception('Could not launch mail client');
  }
}
