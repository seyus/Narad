import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:narad/utils/failure.dart';

import 'cloud_message_repository.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.max,
);

class CloudMessagingImpl implements CloudMessageRepository {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  static bool isConfigured = false;
  static String previousMessageId = '';

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  Future<void> configure(context) async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    if (!isConfigured) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message){
        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channel.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: 'launch_background',
                ),
              ));
        }
        },
      );
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Navigator.pushNamed(context, '/message',
            );
        },
      );
      isConfigured = true;
    }
  }

  @override
  Future<String> getToken() async {
    try {
      String token = await fcm.getToken();
      return token;
    } catch (e) {
      throw UnImplementedFailure();
    }
  }
}