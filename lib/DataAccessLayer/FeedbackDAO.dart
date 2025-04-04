import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackDAO {
  static void storeFeedback(String feedback) {
    FirebaseFirestore.instance.collection('feedback').add({'feedback': feedback});
  }
}
