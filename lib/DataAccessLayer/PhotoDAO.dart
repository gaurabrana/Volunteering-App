import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PhotoDAO {
  static String defaultProfilePictureURL =
      "https://firebasestorage.googleapis.com/v0/b/votingsystem-bd00a.appspot.com/o/profile_photos%2Fprofile%20picture%20default.png?alt=media&token=816a959f-542f-4b72-ba0a-434effa99470";
  static String teamDefaultProfilePictureURL =
      "https://firebasestorage.googleapis.com/v0/b/votingsystem-bd00a.appspot.com/o/profile_photos%2Fteam%20profile%20picture%20default.png?alt=media&token=53d5c838-b416-476c-83fa-f63a33d6d11b";
  static String defaultVolunteeringPhotoURL =
      "https://firebasestorage.googleapis.com/v0/b/votingsystem-bd00a.appspot.com/o/volunteering_photos%2Fdefault%20volunteering%20photo.png?alt=media&token=2803bf28-56fe-48e6-bee6-5036a34675cf";

  static String getDefaultProfilePictureURL() {
    return defaultProfilePictureURL;
  }

  static Future<String?> uploadImageToFirebaseStorage(File image) async {
    try {
      var snapshot = await firebase_storage.FirebaseStorage.instance.ref('profile_photos/${DateTime.now().toString()}').putFile(image);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      //print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  static Future<void> storeImageUrlInFirestore(String userId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').where('UID', isEqualTo: userId).get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'profilePhotoUrl': imageUrl});
        });
      });
    } catch (e) {
      //print('Error storing image URL in Firestore: $e');
    }
  }

  static Future<void> storeTeamImageUrlInFirestore(String teamId, String imageUrl) async {
    try {
      DocumentReference teamRef = FirebaseFirestore.instance.collection('teams').doc(teamId);
      await teamRef.update({'profilePhotoUrl': imageUrl});
    } catch (e) {
      //print('Error storing image URL in Firestore: $e');
    }
  }

  static Future<String> getUserProfilePhotoUrlFromFirestore(String? userId) async {
    if (userId == null) {
      return defaultProfilePictureURL;
    }
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('UID', isEqualTo: userId).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        if (userDoc.exists && userDoc['profilePhotoUrl'] != null) {
          return userDoc['profilePhotoUrl'];
        }
      }
      return defaultProfilePictureURL;
    } catch (e) {
      //print('Error retrieving image URL from Firestore: $e');
      return defaultProfilePictureURL;
    }
  }

  static Future<String> getTeamProfilePhotoUrlFromFirestore(String teamId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();

      if (doc.exists && doc['profilePhotoUrl'] != null) {
        return doc['profilePhotoUrl'];
      }
      return teamDefaultProfilePictureURL;
    } catch (e) {
      //print('Error retrieving image URL from Firestore: $e');
      return teamDefaultProfilePictureURL;
    }
  }
}
