import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class NotificationsServices {


  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "pest-control-b0140",
      "private_key_id": "93b2d68b6d2a4b6a646dd61735ab033b8208b73e",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDQ9Y8OtW6U+hPS\njHDus695wWpoIljq56jDLE/c8GFhBTR3I9bU4VLUEg8Q1OelaEd8oGFZt77t/ebE\nzMWmJqK6Xc+aYFqf3V3hkoOCT6IIBCmR7dpA7rHyBAh3HLKsMXj1phkX/yPUaB+6\nxRmJQpwjBeP5TkFYeHHzawieslZC5ccGEbyBXq8yC9argUUqV7/fEWHzH0bB9j+R\nN6fvR/QH1pyZhI8OLftLNTKBxfegFS9hgXQwdcjW1TCv93u9fYnoVrfPZOTXTa/Y\nnPYnUk+nphoxxq7dEX56n63Vn4Iu+QKIxXf5LvLqbpcMLRbi1WdmobYeIT0E1prX\n4+4ReyYtAgMBAAECggEAEYcLgysWVcI9T+uuXGNvnGmsLIR3C2s3pXlt0IVMUchP\nPJAhyNUGrtm98EY/kQkUeAB28gDe79UcmpTnnlZ+z12nmJYs+9xkb9Orms5ls8Dv\noLlAFbK/8+JBOIaMeTOkJwzR7Yid/4blZHP8fp46/RgVJZgaFJrzyfyIKlGguTco\nmv4Mzz3d5ZuqH2YzMqEfU48LafinWCqyKJaKWWssibe81MQCqeRQFH4oItCzq+95\nsTNRwlhAFoP7G/v8hiPCQUz924zyLUiU7yJ4S3jLZSiMkFgENqfOignrlLj3nCRa\nhGPA74jzt/jSZpCKYRh/lXIAEYdL6BdnHSsWMTxl+QKBgQDxMApZK26Cdve8S7rO\n3bA67IfAIy5LufJWXLo9aSdx3i+n4Oz5SgawNsC2d7fi7RYDh9jcwjPFpyJH0bh/\nGMRQg54SlThhl6vNrcbsEwg4qsNxYJ/VvMYb4zqqPIlvXSBVzE3p/03sMSxCZjyI\n+N56J11gMC+EjzOzTl86Hik3uQKBgQDdytJj8Gv4pRJqcjORcf/N16N3pL7kkfwk\nYXRTlD90lNE59/fJpfphCNM4/kTenWfCPFxHZQlsRJfn1We49ii57pmNrFKwPx6k\ngwqwSSn/nM4WyEzJkG5ZY713Pqu346At8QTUOSXazR5op55u2KKSHV9kNo0ZpF2E\n479i0wg0FQKBgQC28QeIZ2clUnPKwW5q5sB7kVnOpWDCU8K7Ow6Q8ifXOP7Qyc01\nsa6tDnrSbLBwUgD2oJ4fpLZ8X6+i5jKZRQHzSEIoOkNP0ymfkwZlnnIH+Y7RescB\n6nQiRxMCeXSNogeazKL0sJA8bXfyzXVxN8QYx68N/L6uP6ipgvK8NJBzEQKBgQCk\ni22NIXgpDuZbvIAPnsDGCP5IrBvHXZrvrrFrtGdjaWjUFehqXM4loTN7bADSG3s3\n+ioH+aiE/1qnb4a1DULntmGLXtY11Y45RNLwOEeFUOMAufdl7tY/USTmS8N/+MsE\nanRHsmIoMtclk32SBPyPZGU55tLFvFB5X7HEcoX6hQKBgFFq3XlTvPb62A/723lc\nxwa4EuWSfwmqxcTXR0UlPGc6Xozksn/XJSN3PdRfEHeZd7h+b8apGJqRVMuO22Rw\nARSHj405BxO88rjcoma8+ylZUaAdzQZBBN0xv1QmfAIAxnaCsFZaJn6oJX8XQjIB\narLeUb2d7PAyPOFlyDgEvF+G\n-----END PRIVATE KEY-----\n",
      "client_email": "pest-pro-notifications-service@pest-control-b0140.iam.gserviceaccount.com",
      "client_id": "115549966918915155376",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/pest-pro-notifications-service%40pest-control-b0140.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }
    ;

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
    await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client);

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
    const String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/pest-control-b0140/messages:send';

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
    const String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/pest-control-b0140/messages:send';

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
