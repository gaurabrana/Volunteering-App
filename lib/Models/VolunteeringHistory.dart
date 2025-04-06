import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteeringHistory {
  final int hours;
  final int minutes;
  final DateTime date;
  final String role;
  final String task;
  final String userId;
  final String userName;
  final String eventId;
  final String eventName;
  final String organiserId;
  late DocumentReference reference;

  VolunteeringHistory({
    required this.hours,
    required this.minutes,
    required this.date,
    required this.role,
    required this.task,
    required this.userId,
    required this.eventId,
    required this.organiserId,
    required this.eventName,
    required this.userName,
  });

  VolunteeringHistory.fromMap(Map<String, dynamic> map,
      {required this.reference})
      : assert(map['hours'] != null),
        assert(map['minutes'] != null),
        assert(map['date'] != null),
        assert(map['role'] != null),
        assert(map['task'] != null),
        assert(map['userId'] != null),
        assert(map['eventId'] != null),
        assert(map['organiserId'] != null),
        assert(map['eventName'] != null),
        hours = map['hours'],
        minutes = map['minutes'],
        date = (map['date'] as Timestamp).toDate(),
        task = map['task'],
        userId = map['userId'],
        eventId = map['eventId'],
        organiserId = map['organiserId'],
        role = map['role'],
        eventName = map['eventName'],
        userName = map['userName'];

  VolunteeringHistory.fromSnapshot(DocumentSnapshot? snapshot)
      : this.fromMap(snapshot!.data() as Map<String, dynamic>,
            reference: snapshot.reference);

  @override
  String toString() =>
      "VolunteeringHistory<$hours><$minutes><$date><$role><$task><$userId>";
}
