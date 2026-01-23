import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class BirthdayNotificationService {
  final FlutterLocalNotificationsPlugin _notifications;

  BirthdayNotificationService(this._notifications);

  static const _channelId = 'birthdays';
  static const _channelName = 'Compleanni';
  static const _channelDescription = 'Notifiche compleanni giocatori';

  Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  int _notificationId(String playerId) {
    return playerId.hashCode;
  }

  Future<void> scheduleBirthday({
    required String playerId,
    required String fullName,
    required DateTime birthday,
  }) async {
    final now = DateTime.now();

    var nextBirthday = DateTime(now.year, birthday.month, birthday.day, 9);

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day, 9);
    }

    await _notifications.zonedSchedule(
      _notificationId(playerId),
      '🎂 Compleanno!',
      'Oggi è il compleanno di $fullName',
      tz.TZDateTime.from(nextBirthday, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancel(String playerId) async {
    await _notifications.cancel(_notificationId(playerId));
  }
}
