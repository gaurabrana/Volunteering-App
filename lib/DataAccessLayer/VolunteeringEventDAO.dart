import 'package:VolunteeringApp/DataAccessLayer/VolunteeringEventRegistrationsDAO.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/VolunteeringEvent.dart';

class VolunteeringEventDAO {
  String defaultVolunteeringPhotoURL =
      "https://firebasestorage.googleapis.com/v0/b/votingsystem-bd00a.appspot.com/o/volunteering_photos%2Fdefault%20volunteering%20photo.png?alt=media&token=0c1e3b70-16cb-4037-a917-b6c594779387";

  Future<void> addVolunteeringEvent(
      VolunteeringEvent volunteeringEvent) async {
    try {
      await FirebaseFirestore.instance
          .collection('volunteeringEvents')
          .doc()
          .set({
        'date': volunteeringEvent.date,
        'name': volunteeringEvent.name,
        'description': volunteeringEvent.description,
        'location': volunteeringEvent.location,
        'organiserContactConsent': volunteeringEvent.organiserContactConsent,
        'type': volunteeringEvent.type,
        'organiserUID': volunteeringEvent.organiserUID,
        'website': volunteeringEvent.website,
        'photoUrls': volunteeringEvent.photoUrls,
        'longitude': volunteeringEvent.longitude,
        'latitude': volunteeringEvent.latitude,
        'online': volunteeringEvent.online,
      });
    } catch (e) {
      //print('Error storing volunteering event details: $e');
    }
  }

  Future<VolunteeringEvent?> getVolunteeringEvent(String eventId) async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .doc('volunteeringEvents/$eventId')
          .get();
      if (snapshot.exists) {
        return VolunteeringEvent.fromSnapshot(snapshot);
      } else {
        return null;
      }
    } catch (e) {
      //print("Error fetching volunteering event: $e");
      return null;
    }
  }

  Future<List<VolunteeringEvent>?>
      getAllFutureVolunteeringEventsWithStatus(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringEvents')
          .where('date', isGreaterThanOrEqualTo: DateTime.now())
          .get();

      final List<VolunteeringEvent> updatedEvents = [];

      for (final doc in querySnapshot.docs) {
        final VolunteeringEvent event = VolunteeringEvent.fromSnapshot(doc);

        final registration =
            await VolunteeringEventRegistrationsDAO().getUserRegistrationStatus(
          userId: userId,
          eventId: doc.id,
        );

        final eventWithStatus =
            event.copyWith(currentUserRegistration: registration);
        updatedEvents.add(eventWithStatus);
      }

      return updatedEvents;
    } catch (e) {
      print(
          'Error retrieving volunteering events with registration status: $e');
      return null;
    }
  }

  Future<List<VolunteeringEvent>?>
      getAllFutureVolunteeringEvents() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringEvents')
          .where('date', isGreaterThanOrEqualTo: DateTime.now())
          .get();

      return querySnapshot.docs
          .map((doc) => VolunteeringEvent.fromSnapshot(doc))
          .toList();
    } catch (e) {
      //print('Error retrieving volunteering events from Firestore: $e');
      return null;
    }
  }

  Future<List<VolunteeringEvent>?> getEventsByOrganiserUID(
      String organiserUID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringEvents')
          .where('organiserUID', isEqualTo: organiserUID)
          .get();

      return querySnapshot.docs
          .map((doc) => VolunteeringEvent.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching events by organiserUID: $e');
      return null;
    }
  }
}
