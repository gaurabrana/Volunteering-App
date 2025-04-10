import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Models/VolunteeringEvent.dart';
import '../helper.dart';
import 'Leaderboard.dart';
import 'NavBarManager.dart';
import 'SearchVolunteering.dart';
import 'homepage.dart';

class CommonHelper {
  static void redirectToAnotherPage(
      {required int indexToNavigate,
      required GlobalKey<NavigatorState> mainNavigatorKey,
      required GlobalKey<NavigatorState> logInNavigatorKey,
      required BuildContext context}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NavBarManager(
          initialIndex: indexToNavigate,
          searchVolunteeringPage: SearchVolunteeringPage(),
          feedPage: Homepage(
            mainNavigatorKey: mainNavigatorKey,
            logInNavigatorKey: logInNavigatorKey,
          ),
          leaderboardPage: LeaderboardPage(),
          mainNavigatorKey: mainNavigatorKey,
          logInNavigatorKey: logInNavigatorKey,
        ),
      ),
    );
  }

  static bool isFutureDate(DateTime date) {
    // Get the current date and time
    DateTime currentDateTime = DateTime.now();

    // Check if _date is in the future
    return date.isAfter(currentDateTime);
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("failed to login with google account with error $e");
      return null;
    }
  }

  static Future<void> sendNotificationToAssignedUser(
      String assignedUserId, String eventId) async {
    try {
      // Retrieve User B's FCM token from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(assignedUserId)
          .get();
      String? fcmToken = userDoc['token'];

      if (fcmToken != null) {
        // Prepare the notification payload
        Map<String, Map<String, Object>> message = prepareNotificationBody(
            fcmToken: fcmToken,
            title: "Volunteer Assignment",
            body: "You have been assigned to an event",
            data: {"id": eventId});

        await FCMService.getAuthenticatedClient();
        await FCMService.sendNotification(message);
      } else {
        print('FCM Token not found for the assigned user.');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static Map<String, Map<String, Object>> prepareNotificationBody(
      {required String fcmToken,
      required String title,
      required String body,
      required Map<String, String> data}) {
    final message = {
      "message": {
        "token": fcmToken,
        "notification": {"title": title, "body": body},
        "data": data,
      }
    };
    return message;
  }
}

class CommonWidget {
  // Helper method to build each event card
  static Widget buildEventCard(VolunteeringEvent event, BuildContext context) {
    Color? statusColor;
    String? statusText;

    if (event.currentUserRegistration != null) {
      if (event.currentUserRegistration!.isAssigned) {
        statusColor = Colors.green;
        statusText = "Assigned";
      } else {
        statusColor = Colors.orange;
        statusText = "Applied";
      }
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      event.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${event.date.toLocal().toString().split(' ')[0]} at ${event.location}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
              if (statusText != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
