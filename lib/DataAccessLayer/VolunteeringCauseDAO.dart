import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/VolunteeringCause.dart';

class VolunteeringCauseDAO {
  static final List<String> volunteeringTypes = ["Other", "Education", "Environment", "Health", "Vulnerable communities"];

  static Future<void> addVolunteeringCause(VolunteeringCause volunteeringCause) async {
    try {
      await FirebaseFirestore.instance.collection('volunteeringCauses').doc().set({
        'name': volunteeringCause.name,
      });
    } catch (e) {
      //print('Error storing cause: $e');
    }
  }

  static Future<List<String>> getAllCauses() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('volunteeringCauses').get();
    return querySnapshot.docs.map((doc) => VolunteeringCause.fromSnapshot(doc).name).toList();
  }
}
