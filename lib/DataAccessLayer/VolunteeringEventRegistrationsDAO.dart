import 'package:cloud_firestore/cloud_firestore.dart';

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

  static Future<List<VolunteeringEventRegistration>> getAllEventIdsForUser(String userId) async {
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

  static Future<List<VolunteeringEventRegistration>> getAllUserIdsForEvent(String eventId) async {
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

  static Future<void> assignVolunteerToEvent(
      String docId, String startDate, String endDate) async {
    try {
      await FirebaseFirestore.instance
          .collection('volunteeringEventRegistrations')
          .doc(docId)
          .update({
        'isAssigned': true,
        'startDate': startDate,
        'endDate': endDate,
        'lastUpdated': FieldValue.serverTimestamp(), // optional
      });
    } catch (e) {
      print('Error assigning volunteer to the event: $e');
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
          isAssigned: data.containsKey('isAssigned') ? doc['isAssigned'] ?? false : null,
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
