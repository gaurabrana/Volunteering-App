import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final bool favourite;
  final String source;
  final DocumentReference reference;

  Article.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['title'] != null),
        assert(map['description'] != null),
        assert(map['date'] != null),
        assert(map['category'] != null),
        assert(map['favourite'] != null),
        assert(map['source'] != null),
        title = map['title'],
        category = map['category'],
        description = map['description'],
        date = (map['date'] as Timestamp).toDate(),
        favourite = map['favourite'],
        source = map['source'];

  Article.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "Record<$title:$description:$date:$category:$favourite:$source>";
}
