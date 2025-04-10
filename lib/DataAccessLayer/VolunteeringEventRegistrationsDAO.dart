import 'dart:convert';

import 'package:HeartOfExperian/helper.dart';
import 'package:HeartOfExperian/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:http/http.dart' as http;

import '../Models/VolunteeringEventRegistration.dart';

class VolunteeringEventRegistrationsDAO {
  static Future<void> addVolunteeringEventRegistration(
      VolunteeringEventRegistration volunteeringEventRegistration) async {
    try {
      await FirebaseFirestore.instance
          .collection('volunteeringEventRegistrations')
          .doc()
          .set({
        'userId': volunteeringEventRegistration.userId,
        'eventId': volunteeringEventRegistration.eventId,
        'isAssigned': volunteeringEventRegistration.isAssigned
      });
    } catch (e) {
      print('Error storing registration: $e');
    }
  }

  static Future<void> removeVolunteeringEventRegistration(
      String userId, String eventId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringEventRegistrations')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      } else {
        print('No matching document found for deletion');
      }
    } catch (e) {
      print('Error removing registration: $e');
    }
  }

  static Future<List<VolunteeringEventRegistration>> getAllEventIdsForUser(
      String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringEventRegistrations')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => VolunteeringEventRegistration.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching registrations: $e');
      return [];
    }
  }

  static Future<List<VolunteeringEventRegistration>> getAllUserIdsForEvent(
      String eventId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringEventRegistrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      return querySnapshot.docs
          .map((doc) => VolunteeringEventRegistration.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching registrations: $e');
      return [];
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
        final message = {
          "message": {
            "token": fcmToken,
            "notification": {
              "title": "Volunteer Assignment",
              "body": "You have been assigned to an event."
            },
            "data": {
              "id": eventId,
            },
          }
        };

        await JWTHelper.loadJWTtoken(message);
      } else {
        print('FCM Token not found for the assigned user.');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static Future<VolunteeringEventRegistration?> getUserRegistrationStatus({
    required String userId,
    required String eventId,
  }) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('volunteeringEventRegistrations')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        var data = doc.data() as Map<String, dynamic>;
        return VolunteeringEventRegistration(
          userId: doc['userId'],
          eventId: doc['eventId'],
          isAssigned: data.containsKey('isAssigned')
              ? doc['isAssigned'] ?? false
              : null,
          assignedStartDate: data.containsKey('assignedStartDate') &&
                  data['assignedStartDate'] != null
              ? (data['assignedStartDate'] as Timestamp).toDate()
              : null,
          assignedEndDate: data.containsKey('assignedEndDate') &&
                  data['assignedEndDate'] != null
              ? (data['assignedEndDate'] as Timestamp).toDate()
              : null,
        );
      } else {
        return null; // user has not applied
      }
    } catch (e) {
      print("Error fetching registration status: $e");
      return null;
    }
  }
}
