import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/core/notifications/flutter_notification_plugin_provider.dart';
import 'package:timezone/timezone.dart' as tz;

final matchNotificationServiceProvider = Provider<MatchNotificationService>((
  ref,
) {
  final plugin = ref.read(flutterLocalNotificationsPluginProvider);
  final service = MatchNotificationService(plugin);
  service.init();
  return service;
});

class MatchNotificationService {
  final FlutterLocalNotificationsPlugin _notifications;

  MatchNotificationService(this._notifications);

  static const _channelId = 'matches';
  static const _channelName = 'Partite';
  static const _channelDescription = 'Promemoria partite imminenti';

  /// Quanto tempo prima del fischio d'inizio arriva il promemoria.
  static const Duration reminderOffset = Duration(hours: 3);

  Future<void> init() async {
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

  int _notificationId(String matchId) => matchId.hashCode.abs();

  /// Programma (o ri-programma) il promemoria per una partita. Se la partita
  /// è già stata giocata, o l'orario del promemoria è già passato, non
  /// programma nulla e cancella eventuali notifiche già pianificate per
  /// quella partita.
  Future<void> scheduleMatchReminder({
    required String matchId,
    required DateTime matchDate,
    required bool played,
    String? homeTeamName,
    String? awayTeamName,
  }) async {
    await cancel(matchId);

    if (played) return;

    final reminderTime = matchDate.subtract(reminderOffset);
    if (reminderTime.isBefore(DateTime.now())) return;

    final hasTeamNames = homeTeamName != null && awayTeamName != null;
    final body = hasTeamNames
        ? '$homeTeamName - $awayTeamName tra ${reminderOffset.inHours} ore'
        : 'La tua squadra gioca tra ${reminderOffset.inHours} ore';

    await _notifications.zonedSchedule(
      id: _notificationId(matchId),
      title: '⚽ Partita in arrivo!',
      body: body,
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(String matchId) async {
    await _notifications.cancel(id: _notificationId(matchId));
  }
}
