import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteeringEventRegistration {
  final String userId;
  final String eventId;
  final bool isAssigned;
  final DateTime? assignedStartDate;
  final DateTime? assignedEndDate;
  late DocumentReference reference;

  VolunteeringEventRegistration({
    required this.userId,
    required this.eventId,
    required this.isAssigned,
    this.assignedStartDate,
    this.assignedEndDate,
  });

  VolunteeringEventRegistration.fromMap(Map<String, dynamic> map,
      {required this.reference})
      : assert(map['userId'] != null),
        assert(map['eventId'] != null),
        userId = map['userId'],
        eventId = map['eventId'],
        isAssigned = map['isAssigned'],
        assignedStartDate = map['assignedStartDate'] != null
            ? (map['assignedStartDate'] as Timestamp).toDate()
            : null,
        assignedEndDate = map['assignedEndDate'] != null
            ? (map['assignedEndDate'] as Timestamp).toDate()
            : null;

  VolunteeringEventRegistration.fromSnapshot(DocumentSnapshot? snapshot)
      : this.fromMap(snapshot!.data() as Map<String, dynamic>,
            reference: snapshot.reference);

  @override
  String toString() => "VolunteeringEventRegistration<$userId><$eventId>";
}
