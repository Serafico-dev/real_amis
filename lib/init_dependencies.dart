import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:real_amis/core/configs/locale/local_language.dart';
import 'package:real_amis/core/notifications/birthday_notification_service.dart';
import 'package:real_amis/core/secrets/app_secrets.dart';
import 'package:real_amis/core/storage/secure_local_storage.dart';
import 'package:real_amis/core/storage/secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalization localization = FlutterLocalization.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();

  await localization.ensureInitialized();
  localization.init(
    mapLocales: [
      const MapLocale('en', AppLocale.english),
      const MapLocale('it', AppLocale.italian),
    ],
    initLanguageCode: 'it',
  );

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Rome'));

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(settings: settings);

  final birthdayService = BirthdayNotificationService(
    flutterLocalNotificationsPlugin,
  );
  await birthdayService.init();

  final secureStorage = SecureStorage();
  await Supabase.initialize(
    url: AppSecrets.url,
    anonKey: AppSecrets.anonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureLocalStorage(secureStorage),
      authFlowType: AuthFlowType.pkce,
    ),
  );

  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

  await Hive.openBox('matchesBox');
  await Hive.openBox('teamsBox');
  await Hive.openBox('playersBox');
  await Hive.openBox('leaguesBox');
  await Hive.openBox('scoresBox');
  await Hive.openBox('eventsBox');
}
