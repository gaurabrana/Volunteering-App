import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteeringCause {
  final String name;
  final DocumentReference reference;

  VolunteeringCause.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['name'] != null),
        name = map['name'];

  VolunteeringCause.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "VolunteeringCause<$name>";
}
