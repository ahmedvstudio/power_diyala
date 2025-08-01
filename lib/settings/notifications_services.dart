import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:power_diyala/widgets/widgets.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('notification_icon');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      String? payload = notificationResponse.payload;
      if (payload != null) {
        // Handle the payload as needed
        if (kDebugMode) {
          print('Received payload: $payload');
        }
        // Navigate or take action based on the payload
      }
    });
  }

  Future<bool> requestNotificationPermission() async {
    PermissionStatus notificationStatus;

    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;

      // Request notification permission for Android 13+ (SDK 33+)
      if (info.version.sdkInt >= 33) {
        notificationStatus = await Permission.notification.request();
      } else {
        // Check for battery optimizations on Android
        if (await Permission.ignoreBatteryOptimizations.isDenied) {
          final batteryOptimizationStatus =
              await Permission.ignoreBatteryOptimizations.request();

          if (!batteryOptimizationStatus.isGranted) {
            logger.i(
                'Battery optimization permission denied. Please enable it in settings.');

            return false;
          }
        }
        return true; // For older Android versions
      }
    } else if (Platform.isIOS) {
      // Request notification permission for iOS
      notificationStatus = await Permission.notification.request();
    } else {
      return false;
    }

    if (notificationStatus.isGranted) {
      return true;
    } else if (notificationStatus.isDenied) {
      logger.e('Notification permission denied. Please enable it in settings.');
    } else if (notificationStatus.isPermanentlyDenied) {
      logger.e(
          'Notification permission permanently denied. Please enable it in settings.');

      await openAppSettings();
    }

    return false;
  }

  Future<void> showNotification({
    required BuildContext context,
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
    String? summary,
    List<String>? lines,
  }) async {
    var status = await Permission.notification.status;

    if (status.isGranted) {
      return notificationsPlugin.show(
          id,
          title,
          body,
          NotificationDetails(
              android: AndroidNotificationDetails(
            'Test Notification',
            'Test Notification',
            priority: Priority.high,
            importance: Importance.max,
            styleInformation: InboxStyleInformation(lines ?? [],
                contentTitle: title,
                summaryText: summary,
                htmlFormatLines: true,
                htmlFormatContentTitle: true,
                htmlFormatSummaryText: true),
          )));
    } else {
      final snackBar = SnackBar(
        content: const Text("Notification Permission Needed"),
        action: SnackBarAction(
          label: "Settings",
          onPressed: () async {
            await requestNotificationPermission();
          },
        ),
        duration: const Duration(seconds: 3),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Timer(snackBar.duration, () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });

      return;
    }
  }

  Future<void> scheduleNotesNotification({
    required int id,
    required String title,
    required String body,
    required String payLoad,
    required String summary,
    required List<String> lines,
    required BuildContext context,
    required DateTime scheduledNotificationDateTime,
  }) async {
    var status = await Permission.notification.status;

    logger.i(
        'Scheduling notification with ID: $id at $scheduledNotificationDateTime');
    try {
      if (status.isGranted) {
        await notificationsPlugin.zonedSchedule(
          id,
          lines.isNotEmpty ? title : summary,
          lines.isNotEmpty ? lines.first : body,
          tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'Notes Notification',
              'Notes Notification',
              importance: Importance.max,
              priority: Priority.high,
              styleInformation: lines.isNotEmpty
                  ? InboxStyleInformation(
                      lines,
                      contentTitle: title,
                      summaryText: summary,
                    )
                  : BigTextStyleInformation(
                      body,
                      summaryText: summary,
                    ),
            ),
          ),
          payload: payLoad,
          // uiLocalNotificationDateInterpretation:
          //     UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        logger.i('Notification scheduled successfully for ID: $id');
        showToasty('Notification Scheduled Successfully', Colors.greenAccent,
            Colors.black);
      } else {
        final snackBar = SnackBar(
          content: const Text("Notification Permission Needed"),
          action: SnackBarAction(
            label: "Settings",
            onPressed: () async {
              await requestNotificationPermission();
            },
          ),
          duration: const Duration(seconds: 3),
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Timer(snackBar.duration, () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        });
      }
    } catch (e) {
      logger.e('Error scheduling notification for ID: $id - $e');
      showToasty('Wrong Date !', Colors.red, Colors.white);
    }
  }

  void cancelNoteNotification(int id) async {
    await notificationsPlugin.cancel(id);
    showToasty(
        'Notification Cancelled Successfully', Colors.amber, Colors.black);
  }

  void cancelAllNotification() async {
    await notificationsPlugin.cancelAll();
    showToasty(
        'All Notification Cancelled Successfully', Colors.amber, Colors.black);
  }
}
