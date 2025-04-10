import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/fcm/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

class JWTHelper {
  static Future<void> loadJWTtoken(notificationMessage) async {
    // Load your service account credentials (jwt.keys.json)
    final jsonString = await loadJsonAsset();
    if (jsonString == null) {
      return;
    }
    final jsonData = jsonDecode(jsonString);

    // Create a JWT client
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(jsonData),
      [
        'https://www.googleapis.com/auth/firebase.messaging',
        'https://www.googleapis.com/auth/cloud-platform' // General Cloud API scope
      ],
    );

    final message = FirebaseCloudMessagingApi(client);
    final SendMessageRequest request =
        SendMessageRequest.fromJson(notificationMessage);

    // Send the message using the API
    try {
      final response = await message.projects.messages
          .send(request, 'projects/${jsonData['project_id']}');
      print('Notification sent successfully: ${response.toJson()}');
    } catch (e) {
      print('Error sending notification: $e');
    }

    // Don't forget to close the client after you're done
    client.close();
  }

  static Future<String?> loadJsonAsset() async {
    try {
      // Load the asset using rootBundle
      final jsonString =
          await rootBundle.loadString('assets/volunteer-impact.json');
      return jsonString;
    } catch (e) {
      return null;
    }
  }
}
