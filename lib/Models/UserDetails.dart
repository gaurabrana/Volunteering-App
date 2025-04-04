import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  final String forename;
  final String surname;
  final String email;
  final String UID;
  final String profilePhotoUrl;
  final String team;
  final DocumentReference reference;

  UserDetails.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['forename'] != null),
        assert(map['surname'] != null),
        assert(map['UID'] != null),
        assert(map['profilePhotoUrl'] != null),
        assert(map['team'] != null),
        assert(map['email'] != null),
        forename = map['forename'],
        surname = map['surname'],
        email = map['email'],
        UID = map['UID'],
        profilePhotoUrl = map['profilePhotoUrl'],
        team = map['team'];

  UserDetails.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "UserDetails<$forename><$UID><$profilePhotoUrl><$team>";
}
