import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteeringEventRegistration {
  final String userId;
  final String eventId;
  late DocumentReference reference;

  VolunteeringEventRegistration({required this.userId, required this.eventId});

  VolunteeringEventRegistration.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['userId'] != null),
        assert(map['eventId'] != null),
        userId = map['userId'],
        eventId = map['eventId'];

  VolunteeringEventRegistration.fromSnapshot(DocumentSnapshot? snapshot)
      : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "VolunteeringEventRegistration<$userId><$eventId>";
}
