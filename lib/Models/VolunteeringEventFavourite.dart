import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteeringEventFavourite {
  final String userId;
  final String eventId;
  late DocumentReference reference;

  VolunteeringEventFavourite({required this.userId, required this.eventId});

  VolunteeringEventFavourite.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['userId'] != null),
        assert(map['eventId'] != null),
        userId = map['userId'],
        eventId = map['eventId'];

  VolunteeringEventFavourite.fromSnapshot(DocumentSnapshot? snapshot)
      : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "VolunteeringEventFavourite<$userId><$eventId>";
}
