import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/prayer_time_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Bildirime tıklandığında uygulama açılır
  }

  static Future<bool> requestPermissions() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
      return granted ?? false;
    }
    return true;
  }

  static Future<void> schedulePrayerNotifications(
      List<PrayerTimeModel> prayers) async {
    await _notifications.cancelAll();

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      if (!prayer.notificationEnabled) continue;

      final prayerTime = prayer.time;
      if (prayerTime.isBefore(DateTime.now())) continue;

      // Ezan bildirimi
      await _scheduleNotification(
        id: i,
        title: '🕌 ${prayer.name} Vakti',
        body: '${prayer.arabicName}  •  ${_formatTime(prayerTime)}',
        scheduledTime: prayerTime,
        sound: 'ezan',
      );

      // 10 dakika öncesi hatırlatıcı
      final reminderTime =
          prayerTime.subtract(const Duration(minutes: 10));
      if (reminderTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: i + 100,
          title: '⏰ ${prayer.name} Vaktine 10 Dakika Kaldı',
          body: 'Namaza hazırlanın',
          scheduledTime: reminderTime,
          sound: 'reminder',
        );
      }
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String sound,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'Namaz Vakitleri',
      channelDescription: 'Namaz vakti bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(sound),
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}
