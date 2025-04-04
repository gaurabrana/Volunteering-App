import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/VolunteeringEventFavourite.dart';

class VolunteeringEventFavouritesDAO {
  static Future<void> addVolunteeringEventFavourite(VolunteeringEventFavourite volunteeringEventFavourite) async {
    try {
      await FirebaseFirestore.instance.collection('volunteeringEventFavourites').doc().set({
        'userId': volunteeringEventFavourite.userId,
        'eventId': volunteeringEventFavourite.eventId,
      });
    } catch (e) {
      //print('Error storing favourite: $e');
    }
  }

  static Future<void> removeVolunteeringEventFavourite(String userId, String eventId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringEventFavourites')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      } else {
        //print('No matching document found for deletion');
      }
    } catch (e) {
      //print('Error removing registration: $e');
    }
  }

  static Future<List<String>> getAllFavouriteEventIdsForUser(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('volunteeringEventFavourites').where('userId', isEqualTo: userId).get();

      return querySnapshot.docs.map((doc) => VolunteeringEventFavourite.fromSnapshot(doc).eventId).toList();
    } catch (e) {
      //print('Error fetching favourites: $e');
      return [];
    }
  }

  static Future<bool> isEventFavouritedByUser(String userId, String eventId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringEventFavourites')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      //print('Error checking if event is favourited: $e');
      return false;
    }
  }
}
