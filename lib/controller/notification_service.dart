import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:parser/view/notification_screen.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted Provisional permission');
    } else {
      Get.snackbar(
        'Notification Disabled!',
        'Allow Notification Permissions!',
        snackPosition: SnackPosition.BOTTOM,
      );
      Future.delayed(Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  Future<String> getToken() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: true,
      criticalAlert: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      print('Token: $token');
      return token!;
    }

    return '';
  }

  void initLocalNotifications(
    BuildContext context,
    RemoteMessage message,
  ) async {
    var androidInitSetting = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    var iOSInitSetting = const DarwinInitializationSettings();
    var initSetting = InitializationSettings(
      android: androidInitSetting,
      iOS: iOSInitSetting,
    );
    await notificationsPlugin.initialize(
      initSetting,
      onDidReceiveNotificationResponse: (payload) {
        handler(context, message);
      },
    );
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${notification!.title}');
        print('Message data: ${notification!.body}');
      }
      if (Platform.isIOS) {
        iOSNotification;
      }
      if (Platform.isAndroid) {
        print('Message data: ${message.data}');
        initLocalNotifications(context, message);
        // handler(context, message);
        showNotification(message);
      }
    });
  }

  //show Notification
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channel.id.toString(),
          channel.name.toString(),
          channelDescription: 'Your channel description',
          importance: Importance.high,
          priority: Priority.high,
          playSound: channel.playSound,
          enableVibration: channel.enableVibration,
          enableLights: channel.enableLights,
        );

    //ios Setting
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    //merge
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    //show
    Future.delayed(Duration.zero, () {
      notificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
        payload: 'my-data',
      );
    });
  }

  //background and terminated
  void offNotifications(BuildContext context) {
    //background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handler(context, message);
    });

    //terminate
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null && message.data.isNotEmpty) {
        handler(context, message);
      }
    });
  }

  //handler
  Future<void> handler(BuildContext context, RemoteMessage message) async {
    Get.to(() => NotificationScreen(message: message));
  }

  //ios Foreground Notification
  Future iOSNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}
