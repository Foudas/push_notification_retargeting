import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

import 'main.dart';
import 'notification_list.dart';

void localNotificationCheck() {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int yearOfLastNotifInit;
  int monthOfLastNotifInit;
  int dayOfLastNotifInit;

  _prefs.then((SharedPreferences prefs) {
    yearOfLastNotifInit = (prefs.getInt('yearOfLastNotifInit') ?? 0);
    monthOfLastNotifInit = (prefs.getInt('monthOfLastNotifInit') ?? 0);
    dayOfLastNotifInit = (prefs.getInt('dayOfLastNotifInit') ?? 0);

    final lastNotifInit = DateTime(yearOfLastNotifInit, monthOfLastNotifInit - 1, dayOfLastNotifInit);
    final dateToday = DateTime.now();
    final difference = dateToday.difference(lastNotifInit).inDays;

    if (difference.abs() > 10) {
      print('xxx localNotificationCheck difference.abs() > 10');
      print('xxx ekteloume synarthsh');
      prefs.setInt("yearOfLastNotifInit", dateToday.year);
      prefs.setInt("monthOfLastNotifInit", dateToday.month);
      prefs.setInt("dayOfLastNotifInit", dateToday.day);
      _createLocalNotifications();
    } else {
      print('xxx localNotificationCheck else is called');
    }

    // prefs.setInt("yearOfLastNotifInit", dateToday.year + 1);
    // print('yearOfLastNotifInit year+1');
  });
}

void _createLocalNotifications() {
  for (var i = 0; i <= 9; i++) {
    _scheduleDailyTenAMNotification(i);
  }
}

Future<void> _scheduleDailyTenAMNotification(int index) async {
  int zeroOrOne = Random().nextInt(2); // 0 or 1
  final randomIndex = index + 10 * zeroOrOne;

  await flutterLocalNotificationsPlugin.zonedSchedule(
    randomIndex,
    notificationList[randomIndex]['title'],
    notificationList[randomIndex]['main_context'],
    //nextInstanceOfTenAM(index), // <= We need to use the [index] variable here
    // for testing every 5 seconds
    tz.TZDateTime.now(tz.local).add(Duration(seconds: 5 * index)),
    NotificationDetails(
      android: AndroidNotificationDetails(
        randomIndex.toString(),
        notificationList[randomIndex]['title'].toString(),
        channelDescription: notificationList[randomIndex]['main_context'].toString(),
      ),
    ),
    androidAllowWhileIdle: true,
    payload: notificationList[randomIndex]['payloadScreen'],
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

tz.TZDateTime nextInstanceOfTenAM(int index) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local).add(Duration(days: index));
  print('ooo nextInstanceOfTenAM year: ${now.year}');
  print('ooo nextInstanceOfTenAM month: ${now.month}');
  print('ooo nextInstanceOfTenAM day: ${now.day}');

  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);

  /// I commented out the lines of code below, because most of the times
  /// 2 different notifs would be schedule on the same time the next day.
  // if (scheduledDate.isBefore(now)) {
  //   scheduledDate = scheduledDate.add(const Duration(days: 1));
  // }
  return scheduledDate;
}

Future<void> cancelNotification() async {
  await flutterLocalNotificationsPlugin.cancel(0);
}
