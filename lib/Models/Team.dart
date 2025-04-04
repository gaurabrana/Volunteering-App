import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String name;
  final String profilePhotoUrl;
  final DocumentReference reference;

  Team.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['name'] != null),
        assert(map['profilePhotoUrl'] != null),
        name = map['name'],
        profilePhotoUrl = map['profilePhotoUrl'];

  Team.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "Team<$name><$profilePhotoUrl>";
}
