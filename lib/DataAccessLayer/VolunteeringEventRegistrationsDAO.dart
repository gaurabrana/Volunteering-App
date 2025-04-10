import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/Notification_Model.dart';
import '../Models/VolunteeringEvent.dart';
import '../Models/VolunteeringEventRegistration.dart';
import '../Pages/common_helper.dart';

class VolunteeringEventRegistrationsDAO {
  static Future<void> addVolunteeringEventRegistration(
      VolunteeringEventRegistration volunteeringEventRegistration,
      String organiserId,
      VolunteeringEvent event) async {
    try {
      await FirebaseFirestore.instance
          .collection('volunteeringEventRegistrations')
          .doc()
          .set({
        'userId': volunteeringEventRegistration.userId,
        'eventId': volunteeringEventRegistration.eventId,
        'isAssigned': volunteeringEventRegistration.isAssigned
      });
      NotificationMessage message = CommonHelper.prepareNotificationBody(
          title: "Application Request",
          body:
              "A volunteer ${FirebaseAuth.instance.currentUser?.displayName ?? ''} has applied for event: ${event.name}",
          data: {"id": volunteeringEventRegistration.eventId});

      await CommonHelper.sendNotificationToAssignedUser(organiserId, message);
    } catch (e) {
      print('Error storing registration: $e');
    }
  }

  static Future<void> removeVolunteeringEventRegistration(String userId,
      String eventId, String eventName, String organiserId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringEventRegistrations')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        NotificationMessage message = CommonHelper.prepareNotificationBody(
            title: "Application Request Removal",
            body: "A volunteer has opted out of your event: $eventName",
            data: {"id": eventId});
        await CommonHelper.sendNotificationToAssignedUser(organiserId, message);
      } else {
        print('No matching document found for deletion');
      }
    } catch (e) {
      print('Error removing registration: $e');
    }
  }

  Future<List<VolunteeringEventRegistration>> getAllEventIdsForUser(
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

  Future<List<VolunteeringEventRegistration>> getAllUserIdsForEvent(
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

  Future<VolunteeringEventRegistration?> getUserRegistrationStatus({
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
