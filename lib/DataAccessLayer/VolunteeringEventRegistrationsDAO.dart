import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/VolunteeringEventRegistration.dart';

class VolunteeringEventRegistrationsDAO {
  static Future<void> addVolunteeringEventRegistration(VolunteeringEventRegistration volunteeringEventRegistration) async {
    try {
      await FirebaseFirestore.instance.collection('volunteeringEventRegistrations').doc().set({
        'userId': volunteeringEventRegistration.userId,
        'eventId': volunteeringEventRegistration.eventId,
      });
    } catch (e) {
      print('Error storing registration: $e');
    }
  }

  static Future<void> removeVolunteeringEventRegistration(String userId, String eventId) async {
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

  static Future<List<String>> getAllEventIdsForUser(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('volunteeringEventRegistrations').where('userId', isEqualTo: userId).get();

      return querySnapshot.docs.map((doc) => VolunteeringEventRegistration.fromSnapshot(doc).eventId).toList();
    } catch (e) {
      print('Error fetching registrations: $e');
      return [];
    }
  }

  static Future<List<String>> getAllUserIdsForEvent(String eventId) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('volunteeringEventRegistrations').where('eventId', isEqualTo: eventId).get();

      return querySnapshot.docs.map((doc) => VolunteeringEventRegistration.fromSnapshot(doc).userId).toList();
    } catch (e) {
      print('Error fetching registrations: $e');
      return [];
    }
  }
}
