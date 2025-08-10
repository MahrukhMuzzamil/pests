import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:pests247/data/keys.dart';

class NotificationsServices {


  static Future<String> getAccessToken() async {
    // Ensure keys are loaded
    if (Keys.fcmServiceAccount.isEmpty) {
      await Keys.loadAllKeys();
    }

    final Map<String, dynamic> serviceAccountJson = Keys.fcmServiceAccount;
    if (serviceAccountJson.isEmpty) {
      throw Exception('FCM service account is not configured');
    }

    final List<String> scopes = <String>[
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    final auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();

    return credentials.accessToken.data;
  }

  static Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('Notification permission denied');
      } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Notification permission granted');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permission already granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('Notification permission denied');
    }
  }


  static Future<void> sendNotificationToDevice(String userId, BuildContext context, String userName, String message) async {
    final String serverKey = await getAccessToken();
    final String projectId = (Keys.fcmProjectId.isNotEmpty)
        ? Keys.fcmProjectId
        : (Keys.fcmServiceAccount['project_id'] as String? ?? '');
    final String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc['deviceToken'] != null) {
        String deviceToken = userDoc['deviceToken'];

        final Map<String, dynamic> payload = {
          'message': {
            'token': deviceToken,
            'notification': {
              'title': userName,
              'body': message,
            },
          },
        };

        // Send notification
        final response = await http.post(
          Uri.parse(endpointFirebaseCloudMessaging),
          headers: {
            'Authorization': 'Bearer $serverKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully');
        } else {
          print('Failed to send notification: ${response.body}');
        }
      } else {
        print('User not found or device token is missing');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }



  static Future<void> sendLeadRequestQuote(String userId, BuildContext context, String userName) async {
    final String serverKey = await getAccessToken();
    final String projectId = (Keys.fcmProjectId.isNotEmpty)
        ? Keys.fcmProjectId
        : (Keys.fcmServiceAccount['project_id'] as String? ?? '');
    final String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc['deviceToken'] != null) {
        String deviceToken = userDoc['deviceToken'];

        final Map<String, dynamic> payload = {
          'message': {
            'token': deviceToken,
            'notification': {
              'title': 'Pests 247 Lead Request',
              'body': "$userName has requested a quote for a service lead",
            },
          },
        };

        // Send notification
        final response = await http.post(
          Uri.parse(endpointFirebaseCloudMessaging),
          headers: {
            'Authorization': 'Bearer $serverKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully');
        } else {
          print('Failed to send notification: ${response.body}');
        }
      } else {
        print('User not found or device token is missing');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }


}
