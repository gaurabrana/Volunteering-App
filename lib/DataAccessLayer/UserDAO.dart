import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/UserDetails.dart';
import 'PhotoDAO.dart';

class UserDAO {
  String defaultDomain = "@experian.com";

  Future<void> storeUserDetails(
      String userId, String userName, String email, String role,
      {String? photoUrl}) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'UID': userId,
        'name': userName,
        'email': email,
        'role': role,
        'profilePhotoUrl': photoUrl ?? PhotoDAO.getDefaultProfilePictureURL(),
      });
    } catch (e) {
      //print('Error storing user details: $e');
    }
  }

  Future<void> storeOrganisationDetails({
    required String userId,
    required String mission,
    required String activities,
    required String projects,
    required String benefactors,
    required String certificate,
  }) async {
    try {
      // Store data in Firestore under 'organisation_info' collection
      await FirebaseFirestore.instance
          .collection('organisation_info')
          .doc(userId)
          .set({
        'UID': userId,
        'mission': mission,
        'activities': activities,
        'completedProjects': projects,
        'benefactors': benefactors,
        'certificate':
            certificate, // Certificate could be a URL or file reference
      });

      print("Organisation details saved successfully!");
    } catch (e) {
      print('Error storing organisation details: $e');
    }
  }

  // Method to fetch organisation details by userId
  Future<Map<String, dynamic>?> fetchOrganisationDetails(String userId) async {
    try {
      // Get the document reference for the given userId
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('organisation_info')
          .doc(userId)
          .get();

      // Check if the document exists
      if (snapshot.exists) {
        // Return the document data as a Map
        return snapshot.data() as Map<String, dynamic>;
      } else {
        print('No organisation details found for userId: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching organisation details: $e');
      return null;
    }
  }

  Future<UserDetails?> getUserDetails(String? userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('UID', isEqualTo: userId)
        .get();

    // ✅ Loop through and print each document's data
    for (var doc in querySnapshot.docs) {
      print("user data is ${doc.data()}");
    }

    // Convert to model
    final List<UserDetails> users =
        querySnapshot.docs.map((doc) => UserDetails.fromSnapshot(doc)).toList();

    return users.isNotEmpty ? users.first : null;
  }

  Future<List<UserDetails?>> getAllUsers() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs
        .map((doc) => UserDetails.fromSnapshot(doc))
        .toList();
  }

  Future<void> updateName(UserDetails user, String newName) async {
    try {
      await user.reference?.update({'name': newName});
    } catch (error) {
      //print("Error updating user's name: $error");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    } catch (error) {
      //print("Error deleting user: $error");
      throw error;
    }
  }

  Future<void> updateUserToken(String userId, String token) async {
    try {
      // Query Firestore for the user's document
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('UID', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("No user found with the given UID.");
        return;
      }

      // Update the token field for the user's document
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'token': token});
        print("Token updated for user: ${doc.id}");
      }
    } catch (e) {
      print("Error updating user token: $e");
    }
  }

  Future<String?> getFCMToken(String userId) async {
    // Retrieve User FCM token from Firestore
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      String? fcmToken = userDoc['token'];
      return fcmToken;
    } on Exception catch (e) {
      print("Errow while getting fcmToken $e");
      return null;
    }
  }
}
