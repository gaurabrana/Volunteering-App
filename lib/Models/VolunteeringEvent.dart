import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  VolunteeringEvent.fromMap(Map<String, dynamic> map, {required this.reference})
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
        longitude = (map['longitude'] is int) ? (map['longitude'] as int).toDouble() : map['longitude'] as double,
        latitude = (map['latitude'] is int) ? (map['latitude'] as int).toDouble() : map['latitude'] as double,
        location = map['location'],
        description = map['description'],
        website = map['website'],
        date = (map['date'] as Timestamp).toDate(),
        type = map['type'],
        organiserUID = map['organiserUID'],
        photoUrls = List<String>.from(map['photoUrls']);

  VolunteeringEvent.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "VolunteeringEvent<$name><$organiserContactConsent><$date><$type><$location><$description><$website><$organiserUID>";
}
