import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/fcm/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  static AutoRefreshingAuthClient? _client; // Store the client here

  // Load and return the authenticated client
  static Future<AutoRefreshingAuthClient?> getAuthenticatedClient() async {
    if (_client != null) {
      return _client;
    }

    // Load JWT token from service account
    final credentials = await loadJsonAsset();
    if (credentials == null) {
      return null;
    }

    // Create the client using the credentials
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(credentials),
      [
        'https://www.googleapis.com/auth/firebase.messaging',
        'https://www.googleapis.com/auth/cloud-platform' // General Cloud API scope
      ],
    );

    _client = client; // Store the client for reuse
    return _client;
  }

  // Call this method when the app is disposed or no longer needs the client
  static void closeClient() {
    _client?.close();
    _client = null; // Clean up
  }

  // Function to send notification
  static Future<void> sendNotification(
      Map<String, dynamic> notificationMessage) async {
    final client = await getAuthenticatedClient(); // Get the client
    final credentials = await loadJsonAsset();
    if (client == null) {
      print('Error: Unable to authenticate');
      return;
    }

    final message = FirebaseCloudMessagingApi(client);
    final request = SendMessageRequest.fromJson(notificationMessage);

    try {
      final response = await message.projects.messages
          .send(request, 'projects/${credentials['project_id']}');
      print('Notification sent successfully: ${response.toJson()}');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static Future<dynamic> loadJsonAsset() async {
    try {
      // Load the asset using rootBundle
      final jsonString =
          await rootBundle.loadString('assets/volunteer-impact.json');
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }
}
