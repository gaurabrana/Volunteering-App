import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteeringHistory {
  final int hours;
  final int minutes;
  final DateTime date;
  final String type;
  final String cause;
  final String UID;
  late DocumentReference reference;

  VolunteeringHistory({
    required this.hours,
    required this.minutes,
    required this.date,
    required this.type,
    required this.cause,
    required this.UID,
  });

  VolunteeringHistory.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['hours'] != null),
        assert(map['minutes'] != null),
        assert(map['date'] != null),
        assert(map['type'] != null),
        assert(map['cause'] != null),
        assert(map['UID'] != null),
        hours = map['hours'],
        minutes = map['minutes'],
        date = (map['date'] as Timestamp).toDate(),
        type = map['type'],
        UID = map['UID'],
        cause = map['cause'];

  VolunteeringHistory.fromSnapshot(DocumentSnapshot? snapshot)
      : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "VolunteeringHistory<$hours><$minutes><$date><$type><$cause><$UID>";
}
