import 'package:cloud_firestore/cloud_firestore.dart';

class Following {
  final String followerUID;
  final String followingUID;
  late DocumentReference reference;

  Following({required this.followerUID, required this.followingUID});

  Following.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['followingUID'] != null),
        assert(map['followerUID'] != null),
        followerUID = map['followerUID'],
        followingUID = map['followingUID'];

  Following.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "VolunteeringEventRegistration<$followingUID><$followerUID>";
}
