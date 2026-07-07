import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../database/app_database.dart' hide Verse;
import '../constants/bible_metadata.dart';
import '../../domain/entities/verse.dart';
import '../../presentation/providers/settings_providers.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/Mexico_City'));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  Future<bool> requestPermission() async {
    final platform = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (platform != null) {
      final granted = await platform.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> showDailyVerse() async {
    final db = _ref.read(appDatabaseProvider);
    final versionId = _ref.read(activeVersionProvider);
    final map = await db.getDailyVerse(versionId);
    if (map == null) return;
    final verse = Verse.fromMap(map);
    final book = booksById[verse.bookId];
    await _plugin.show(
      1,
      'Versículo del día',
      '${book?.name ?? ''} ${verse.chapter}:${verse.verse} — ${verse.text}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_verse',
          'Versículo del día',
          channelDescription: 'Un versículo cada día',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleDailyVerse(TimeOfDay time) async {
    await _plugin.zonedSchedule(
      2,
      'Versículo del día',
      'Abre la app para ver tu versículo de hoy.',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_verse',
          'Versículo del día',
          channelDescription: 'Un versículo cada día',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleReadingReminder(TimeOfDay time) async {
    await _plugin.zonedSchedule(
      3,
      'Recordatorio de lectura',
      'Tómate un momento para leer la Palabra hoy.',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reading_reminder',
          'Recordatorio de lectura',
          channelDescription: 'Recuerda leer cada día',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancel(2);
    await _plugin.cancel(3);
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
