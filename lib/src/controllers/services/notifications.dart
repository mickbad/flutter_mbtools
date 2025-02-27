// -----------------------------------------------------------------------------
// - Librairie de notifications de l'application
// -----------------------------------------------------------------------------
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:local_notifier/local_notifier.dart';
import 'package:mbtools/mbtools.dart';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
// final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
// final BehaviorSubject<String?> selectNotificationSubject = BehaviorSubject<String?>();
// const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');

// -----------------------------------------------------------------------------
// Classe de gestion des notifications
class mbNotifications {
  // attributs
  String? selectedNotificationPayload;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ---------------------------------------------------------------------------
  // constructeur
  mbNotifications(String iconMaster) {
    if (!kIsWeb && !Platform.isWindows) {
      init(iconMaster);
    }
  }

  Future<void> init(String iconMaster) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(iconMaster);
    const DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    /*
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
        Platform.isLinux
        ? null
        : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    AndroidInitializationSettings initializationSettingsAndroid = new AndroidInitializationSettings(iconMaster);

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationSubject.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      //notificationCategories: darwinNotificationCategories,
    );

    final MacOSInitializationSettings initializationSettingsMacOS =
    MacOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      //notificationCategories: darwinNotificationCategories,
    );

    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          debugPrint('notification payload: $payload');
        }
        selectNotificationSubject.add(payload);
      },
      //backgroundHandler: notificationTapBackground,
    );


     */
  } // fin de la fonction notifications()

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    debugPrint('3-notification payload: $payload');
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    // final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      // debugPrint('1-notification payload: $payload');
    }

    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  // ---------------------------------------------------------------------------
  Future onSelectNotification(String payload) async {
    if (payload.isNotEmpty) {
      // print('2-notification payload: ' + payload);
    }
/*
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    );
*/
  }

  // ---------------------------------------------------------------------------
  // envoi d'une notification basique
  Future<void> sendBasicMessage(
      String title, String description, String payload) async {
    if (Platform.isWindows || Platform.isLinux) {
      // envoi vers la notification windows
      await sendBasicMessageWindows(title, description, payload);
      return;
    }

    try {
      debugPrint("-- sendBasicMessage");

      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              '${ToolsConfigApp.appName.replaceAll(" ", "")}ID',
              ToolsConfigApp.appName,
              channelDescription: '${ToolsConfigApp.appName} Notification',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.show(
          0, title, description, platformChannelSpecifics,
          payload: payload);

      debugPrint("-- sendBasicMessage End");
    } catch (e) {
      debugPrint(e.toString());
    }
  } // fin de la fonction sendBasicMessage()

  Future<void> sendBasicMessageWindows(
      String title, String description, String payload) async {
    // Add in main method.
    await localNotifier.setup(
      appName: ToolsConfigApp.appName,
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );

    LocalNotification notification = LocalNotification(
      title: title,
      body: description,
    );
    notification.show();
  }
} // fin de la classe notifications
