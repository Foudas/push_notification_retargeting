import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notif_testing/second_page.dart';
import 'package:push_notif_testing/widgets.dart';
import 'package:timezone/timezone.dart' as tz;
import 'local_notitication_check.dart';
import 'main.dart';
import 'notification_list.dart';
import 'widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String routeName = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
    _configureSelectNotificationSubject();
    localNotificationCheck();
  }

  void _requestNotificationPermissions() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureSelectNotificationSubject() {
    /// This listener listens on Notification taps
    selectNotificationSubject.stream.listen((String? payload) async {
      print('www _configureSelectNotificationSubject()');
      print('www payload: $payload');

      if (payload == kStringBoards) {
        print('www now we should go to boards');
      } else if (payload == kStringSchedule) {
        print('www now we should go to schedule');
      } else if (payload == kStringNotes) {
        print('www now we should go to notes');
      } else if (payload == kStringDiscover) {
        print('www now we should go to discover');
      }
      await Navigator.pushNamed(context, '/secondPage');
    });
  }

  @override
  void dispose() {
    //didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Text('Tap on a notification when it appears to trigger'
                          ' navigation'),
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show plain notification with payload',
                      onPressed: () async {
                        await _showNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show plain notification that has no title with '
                          'payload',
                      onPressed: () async {
                        await _showNotificationWithNoTitle();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show plain notification that has no body with '
                          'payload',
                      onPressed: () async {
                        await _showNotificationWithNoBody();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with custom sound',
                      onPressed: () async {
                        await _showNotificationCustomSound();
                      },
                    ),
                    if (kIsWeb || !Platform.isLinux) ...<Widget>[
                      PaddedElevatedButton(
                        buttonText: 'Schedule notification to appear in 5 seconds '
                            'based on local time zone',
                        onPressed: () async {
                          await _zonedScheduleNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Repeat notification every minute',
                        onPressed: () async {
                          await _repeatNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Schedule daily 10:00:00 am notification in your '
                            'local time zone',
                        onPressed: () async {
                          await _scheduleDailyTenAMNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Schedule daily 10:00:00 am notification in your '
                            "local time zone using last year's date",
                        onPressed: () async {
                          await _scheduleDailyTenAMLastYearNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Schedule weekly 10:00:00 am notification in your '
                            'local time zone',
                        onPressed: () async {
                          await _scheduleWeeklyTenAMNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Schedule weekly Monday 10:00:00 am notification '
                            'in your local time zone',
                        onPressed: () async {
                          await _scheduleWeeklyMondayTenAMNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Check pending notifications',
                        onPressed: () async {
                          await _checkPendingNotificationRequests();
                        },
                      ),
                    ],
                    PaddedElevatedButton(
                      buttonText: 'Schedule monthly Monday 10:00:00 am notification in '
                          'your local time zone',
                      onPressed: () async {
                        await _scheduleMonthlyMondayTenAMNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Schedule yearly Monday 10:00:00 am notification in '
                          'your local time zone',
                      onPressed: () async {
                        await _scheduleYearlyMondayTenAMNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with no sound',
                      onPressed: () async {
                        await _showNotificationWithNoSound();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Cancel notification',
                      onPressed: () async {
                        await _cancelNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Cancel all notifications',
                      onPressed: () async {
                        await _cancelAllNotifications();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description', importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'plain title', 'plain body', platformChannelSpecifics, payload: 'item x');
  }

  Future<void> _showNotificationWithNoBody() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description', importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(0, 'plain title', null, platformChannelSpecifics, payload: 'item x');
  }

  Future<void> _showNotificationWithNoTitle() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(0, null, 'plain body', platformChannelSpecifics, payload: 'item x');
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> _showNotificationCustomSound() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      channelDescription: 'your other channel description',
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
    );
    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(sound: 'slow_spring_board.aiff');
    const MacOSNotificationDetails macOSPlatformChannelSpecifics = MacOSNotificationDetails(sound: 'slow_spring_board.aiff');
    final LinuxNotificationDetails linuxPlatformChannelSpecifics = LinuxNotificationDetails(
      sound: AssetsLinuxSound('sound/slow_spring_board.mp3'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: macOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'custom sound notification title',
      'custom sound notification body',
      platformChannelSpecifics,
    );
  }

  Future<void> _zonedScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id', 'your channel name', channelDescription: 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> _showNotificationWithNoSound() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('silent channel id', 'silent channel name',
        channelDescription: 'silent channel description', playSound: false, styleInformation: DefaultStyleInformation(true, true));
    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(presentSound: false);
    const MacOSNotificationDetails macOSPlatformChannelSpecifics = MacOSNotificationDetails(presentSound: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics, macOS: macOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, '<b>silent</b> title', '<b>silent</b> body', platformChannelSpecifics);
  }

  Future<void> _checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text('${pendingNotificationRequests.length} pending notification '
            'requests'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _repeatNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('repeating channel id', 'repeating channel name', channelDescription: 'repeating description');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .periodicallyShow(0, 'repeating title', 'repeating body', RepeatInterval.everyMinute, platformChannelSpecifics, androidAllowWhileIdle: true);
  }

  Future<void> _scheduleDailyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'daily scheduled notification title',
      'daily scheduled notification body',
      _nextInstanceOfTenAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails('daily notification channel id', 'daily notification channel name',
            channelDescription: 'daily notification description'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// To test we don't validate past dates when using `matchDateTimeComponents`
  Future<void> _scheduleDailyTenAMLastYearNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'daily scheduled notification title',
        'daily scheduled notification body',
        _nextInstanceOfTenAMLastYear(),
        const NotificationDetails(
          android: AndroidNotificationDetails('daily notification channel id', 'daily notification channel name',
              channelDescription: 'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> _scheduleWeeklyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'weekly scheduled notification title',
        'weekly scheduled notification body',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('weekly notification channel id', 'weekly notification channel name',
              channelDescription: 'weekly notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> _scheduleWeeklyMondayTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'weekly scheduled notification title',
        'weekly scheduled notification body',
        _nextInstanceOfMondayTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('weekly notification channel id', 'weekly notification channel name',
              channelDescription: 'weekly notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> _scheduleMonthlyMondayTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'monthly scheduled notification title',
        'monthly scheduled notification body',
        _nextInstanceOfMondayTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('monthly notification channel id', 'monthly notification channel name',
              channelDescription: 'monthly notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime);
  }

  Future<void> _scheduleYearlyMondayTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'yearly scheduled notification title',
        'yearly scheduled notification body',
        _nextInstanceOfMondayTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('yearly notification channel id', 'yearly notification channel name',
              channelDescription: 'yearly notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTenAMLastYear() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    return tz.TZDateTime(tz.local, now.year - 1, now.month, now.day, 10);
  }

  tz.TZDateTime _nextInstanceOfMondayTenAM() {
    tz.TZDateTime scheduledDate = _nextInstanceOfTenAM();
    while (scheduledDate.weekday != DateTime.monday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
