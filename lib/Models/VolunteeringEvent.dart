import 'package:cloud_firestore/cloud_firestore.dart';

import 'VolunteeringEventRegistration.dart';

class VolunteeringEvent {
  final DateTime date;
  final String type;
  final String name;
  final bool organiserContactConsent;
  final bool online;
  final String description;
  final String location;
  final double longitude;
  final double latitude;
  final String website;
  final String organiserUID;
  List<String> photoUrls;
  late DocumentReference reference;
  final VolunteeringEventRegistration? currentUserRegistration;

  VolunteeringEvent({
    required this.name,
    required this.organiserContactConsent,
    required this.online,
    required this.description,
    required this.location,
    required this.longitude,
    required this.latitude,
    required this.website,
    required this.organiserUID,
    required this.date,
    required this.type,
    required this.photoUrls,
    this.currentUserRegistration,
  });

  VolunteeringEvent.fromMap(Map<String, dynamic> map,
      {required this.reference, this.currentUserRegistration})
      : assert(map['name'] != null),
        assert(map['organiserContactConsent'] != null),
        assert(map['online'] != null),
        assert(map['description'] != null),
        assert(map['location'] != null),
        assert(map['longitude'] != null),
        assert(map['latitude'] != null),
        assert(map['website'] != null),
        assert(map['organiserUID'] != null),
        assert(map['date'] != null),
        assert(map['type'] != null),
        assert(map['photoUrls'] != null),
        name = map['name'],
        organiserContactConsent = map['organiserContactConsent'] as bool,
        online = map['online'] as bool,
        longitude = (map['longitude'] is int)
            ? (map['longitude'] as int).toDouble()
            : map['longitude'] as double,
        latitude = (map['latitude'] is int)
            ? (map['latitude'] as int).toDouble()
            : map['latitude'] as double,
        location = map['location'],
        description = map['description'],
        website = map['website'],
        date = (map['date'] as Timestamp).toDate(),
        type = map['type'],
        organiserUID = map['organiserUID'],
        photoUrls = List<String>.from(map['photoUrls']);

  VolunteeringEvent.fromSnapshot(DocumentSnapshot? snapshot)
      : this.fromMap(snapshot!.data() as Map<String, dynamic>,
            reference: snapshot.reference);

  @override
  String toString() =>
      "VolunteeringEvent<$name><$organiserContactConsent><$date><$type><$location><$description><$website><$organiserUID>";

  VolunteeringEvent copyWith({
    String? name,
    bool? organiserContactConsent,
    bool? online,
    String? description,
    String? location,
    double? longitude,
    double? latitude,
    String? website,
    String? organiserUID,
    DateTime? date,
    String? type,
    List<String>? photoUrls,
    VolunteeringEventRegistration? currentUserRegistration,
    DocumentReference? reference,
  }) {
    return VolunteeringEvent(
      name: name ?? this.name,
      organiserContactConsent:
          organiserContactConsent ?? this.organiserContactConsent,
      online: online ?? this.online,
      description: description ?? this.description,
      location: location ?? this.location,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      website: website ?? this.website,
      organiserUID: organiserUID ?? this.organiserUID,
      date: date ?? this.date,
      type: type ?? this.type,
      photoUrls: photoUrls ?? List.from(this.photoUrls),
      currentUserRegistration:
          currentUserRegistration ?? this.currentUserRegistration,
    )..reference = reference ?? this.reference;
  }
}
