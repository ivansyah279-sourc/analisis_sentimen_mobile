import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationUtil {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification settings and time zones.
  static Future<void> init() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }

      const androidSettings =
          AndroidInitializationSettings("@mipmap/ic_launcher");

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      if (Platform.isIOS) {
        await _notification
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notification.initialize(
        initSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap,
      );

      // ⏰ Inisialisasi timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      log("Error initializing notifications: $e");
    }
  }

  /// Set up notification response listener.
  static StreamController<NotificationResponse> notificationResponseController =
      StreamController<NotificationResponse>.broadcast();
  static void onNotificationTap(
    NotificationResponse notificationResponse,
  ) {
    notificationResponseController.add(notificationResponse);
  }

  /// Show a basic notification with required title and body.
  static Future<void> showBasicNotification({
    required String title,
    required String body,
    int id = 0,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
    bool silent = false,
    String? payload,
  }) async {
    try {
      await _notification.show(
        id,
        title,
        body,
        payload: payload,
        _buildNotificationDetails(
          channelId: "basic_notification",
          channelName: "My Basic Channel",
          importance: importance,
          priority: priority,
          silent: silent,
        ),
      );
      log("Basic notification shown: $title");
    } catch (e) {
      log("Error showing basic notification: $e");
    }
  }

  /// Show a repeating notification every minute.
  static Future<void> showRepeatingNotification(
      {required String title,
      required String body,
      int id = 0,
      RepeatInterval repeatInterval = RepeatInterval.everyMinute,
      Importance importance = Importance.max,
      Priority priority = Priority.high,
      bool silent = false,
      String? payload}) async {
    try {
      await _notification.periodicallyShow(
        id,
        title,
        body,
        repeatInterval,
        payload: payload,
        _buildNotificationDetails(
          channelId: "repeating_notification",
          channelName: "My Repeating Channel",
          importance: importance,
          priority: priority,
          silent: silent,
        ),
      );
      log("Repeating notification shown: $title");
    } catch (e) {
      log("Error showing repeating notification: $e");
    }
  }

  /// Show a scheduled notification after a delay.
  static Future<void> showScheduleNotification(
      {required String title,
      required String body,
      required Duration delay,
      int id = 0,
      Importance importance = Importance.max,
      Priority priority = Priority.high,
      bool silent = false,
      String? payload}) async {
    try {
      await _notification.zonedSchedule(
        id,
        payload: payload,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(delay),
        _buildNotificationDetails(
          // sound: RawResourceAndroidNotificationSound('yaamsallyallaelnaby.mp3'),
          channelId: "schedule_notification",
          channelName: "My Schedule Channel",
          importance: importance,
          priority: priority,
          silent: silent,
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      log("Scheduled notification shown: $title");
    } catch (e) {
      log("Error scheduling notification: $e");
    }
  }

  /// Cancel a specific notification by its ID.
  static Future<void> cancelNotification(int id) async {
    try {
      await _notification.cancel(id);
      log("Notification canceled: ID $id");
    } catch (e) {
      log("Error canceling notification: $e");
    }
  }

  /// Cancel all notifications.
  static Future<void> cancelAllNotifications() async {
    try {
      await _notification.cancelAll();
      log("All notifications canceled");
    } catch (e) {
      log("Error canceling all notifications: $e");
    }
  }

  /// Show a recurring notification with a customizable schedule (e.g., days, weeks).
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    int id = 0,
    int seconds = 0,
    int minutes = 0,
    int hours = 0,
    int days = 0,
    int weeks = 0,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
    bool silent = false,
  }) async {
    final totalDuration = Duration(
      seconds: seconds,
      minutes: minutes,
      hours: hours,
      days: days + (weeks * 7),
    );

    try {
      await showScheduleNotification(
        title: title,
        body: body,
        delay: totalDuration,
        id: id,
        importance: importance,
        priority: priority,
        silent: silent,
      );
      log("Scheduled notification created: $title");
    } catch (e) {
      log("Error scheduling recurring notification: $e");
    }
  }

  /// Show a daily notification at specific hour and minute.
  static Future<void> showDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      final scheduledDate = nextInstanceOfTime(hour, minute);

      await _notification.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _buildNotificationDetails(
          channelId: "daily_notification",
          channelName: "Daily Absen Notification",
          importance: Importance.max,
          priority: Priority.high,
          silent: false,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      log("Daily notification created: $title");
    } catch (e) {
      log("Error scheduling daily notification: $e");
    }
  }

  /// Helper to get the next occurrence of a time
  static tz.TZDateTime nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Helper function to build common notification details.
  static NotificationDetails _buildNotificationDetails({
    required String channelId,
    required String channelName,
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
    bool silent = false,
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: importance,
      priority: priority,
      playSound: !silent,
      sound: silent
          ? null
          : RawResourceAndroidNotificationSound(
              'notifikasi_absen.wav'.split('.').first,
            ),
      enableVibration: !silent,
      vibrationPattern: silent
          ? null
          : Int64List.fromList(
              [
                0,
                2000,
                500,
                2000,
                500,
                2000,
                500,
                2000,
              ],
            ),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: silent ? null : 'notifikasi_absen.wav',
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }
}
