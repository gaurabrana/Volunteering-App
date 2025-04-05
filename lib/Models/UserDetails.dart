import 'package:HeartOfExperian/constants/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  final String name;
  final String email;
  final String UID;
  final String profilePhotoUrl;
  final UserRole role;
  final DocumentReference reference;

  UserDetails.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['name'] != null),
        assert(map['UID'] != null),
        assert(map['profilePhotoUrl'] != null),
        assert(map['role'] != null),
        assert(map['email'] != null),
        name = map['name'],
        email = map['email'],
        UID = map['UID'],
        profilePhotoUrl = map['profilePhotoUrl'],
        role = UserRole.values.firstWhere(
          (element) => element.name == map['role'],
          orElse: () => UserRole.user,
        );

  UserDetails.fromSnapshot(DocumentSnapshot? snapshot)
      : this.fromMap(snapshot!.data() as Map<String, dynamic>,
            reference: snapshot.reference);

  /// fromJson (separate from fromMap) — expects reference explicitly
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails._(
      name: json['name'],
      email: json['email'],
      UID: json['UID'],
      profilePhotoUrl: json['profilePhotoUrl'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      reference: FirebaseFirestore.instance.doc(json['reference']),
    );
  }

  /// toJson (includes reference path as a string)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'UID': UID,
      'profilePhotoUrl': profilePhotoUrl,
      'role': role.name,
      'reference': reference.path, // <- just the path string
    };
  }

  /// Private constructor for manual instantiation
  const UserDetails._({
    required this.name,
    required this.email,
    required this.UID,
    required this.profilePhotoUrl,
    required this.role,
    required this.reference,
  });

  @override
  String toString() =>
      "UserDetails<$name><$UID><$profilePhotoUrl><${role.name}>";
}
