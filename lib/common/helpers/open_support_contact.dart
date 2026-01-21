import 'dart:io';
import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/app_info.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openSupportContact(
  BuildContext context, {
  String email = 'federico.mereu@outlook.it',
}) async {
  final version = await AppInfo.versionWithBuildAsync();
  final platform = Platform.operatingSystem;

  final subject = 'Supporto app Real Amis';
  final body =
      '''
Descrivi il problema:




---
Info tecniche (non rimuovere):
App version: $version
Platform: $platform
''';

  final uri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: {'subject': subject, 'body': body},
  );

  final canLaunch = await canLaunchUrl(uri);

  if (!canLaunch && context.mounted) {
    showSnackBar(context, 'Nessuna app email trovata. Scrivi a $email');
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!launched && context.mounted) {
    showSnackBar(context, 'Impossibile aprire il client email');
  }
}
