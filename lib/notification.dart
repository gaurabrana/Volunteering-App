import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:VolunteeringApp/DataAccessLayer/VolunteeringEventDAO.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Models/VolunteeringEvent.dart';
import 'Pages/VolunteeringEventDetails.dart';

// A class to handle local notification testing
class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int id = 1;

  // Action IDs for different notification actions
  static const String urlLaunchActionId =
      'id_1'; // Action ID for url launch event
  static const String navigationActionId =
      'id_3'; // Action ID for App navigation event

  // Defines a iOS/MacOS notification category for text input actions.
  static const String darwinNotificationCategoryText = 'textCategory';

  // Defines a iOS/MacOS notification category for plain actions.
  static const String darwinNotificationCategoryPlain = 'plainCategory';

  // Function to initialize local notifications
  static initilizeNotification() async {
    // Android initialization settings for local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    // iOS/MacOS notification categories with associated actions
    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];

    // iOS/MacOS initialization settings for local notifications
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: darwinNotificationCategories,
    );

    // Overall initialization settings for local notifications
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Initialize the FlutterLocalNotificationsPlugin with the given settings
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        // Callback when a notification is tapped or an action is selected
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            log("PAYLOAD FROM selectedNotification :: ${notificationResponse.payload}");
            checkNotificationType(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              log("PAYLOAD FROM selectedNotification :: ${notificationResponse.payload}");
            }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  // Callback function for background notification tap event
  @pragma('vm:entry-point')
  static void notificationTapBackground(
      NotificationResponse notificationResponse) {
    log('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      log('notification action tapped with input: ${notificationResponse.input}');
    }
  }

  // Function to check if Android notification permissions are granted
  Future<bool> isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      return granted;
    }
    return false;
  }

  // Function to request notification permissions (iOS/MacOS and Android)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted =
          await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  // Function to show a media-style local notification
  Future<void> showNotificationMediaStyle(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("volunteeringapp", "volunteeringapp",
            groupKey: 'com.volunteeringapp.flutter_push_notifications',
            channelDescription: 'channel description',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            ticker: 'ticker',
            icon: "ic_notification");
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, notification!.title, notification.body, notificationDetails,
        payload: json.encode(message.data));
  }

  // Function to check the type of the notification and take appropriate action
  static Future<void> checkNotificationType(String? data) async {
    if (data != null) {
      final decodedData = json.decode(data);
      final id = decodedData['id'];
      if (id != null) {
        VolunteeringEvent? event =
            await VolunteeringEventDAO().getVolunteeringEvent(id);
        if (event != null) {
          Navigator.of(Get.context!).push(MaterialPageRoute(
            builder: (context) => VolunteeringEventDetailsPage(
              volunteeringEvent: event,
            ),
          ));
        }
      }
    }
  }
}
