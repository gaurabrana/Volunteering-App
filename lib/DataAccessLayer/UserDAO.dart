import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/UserDetails.dart';
import 'PhotoDAO.dart';
import 'TeamDAO.dart';

class UserDAO {
  static const String defaultDomain = "@experian.com";

  static Future<void> storeUserDetails(String userId, String forename, String surname, String team, String email) async {
    try {
      String? teamID = await TeamDAO.getTeamId(team);
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'UID': userId,
        'forename': forename,
        'surname': surname,
        'team': teamID!,
        'email': email,
        'profilePhotoUrl': PhotoDAO.getDefaultProfilePictureURL(),
      });
    } catch (e) {
      //print('Error storing user details: $e');
    }
  }

  static Future<UserDetails?> getUserDetails(String? userId) async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users').where('UID', isEqualTo: userId).get();
    final List<UserDetails> users = querySnapshot.docs.map((doc) => UserDetails.fromSnapshot(doc)).toList();
    return users.isNotEmpty ? users.first : null;
  }

  static Future<List<UserDetails?>> getTeamMembers(String? teamId) async {
    List<UserDetails?> teamMembers = [];
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('users').where('team', isEqualTo: teamId).get();

      teamMembers = querySnapshot.docs.map((doc) => UserDetails.fromSnapshot(doc)).toList();
    } catch (e) {
      //print('Error getting team members: $e');
    }
    return teamMembers;
  }

  static Future<List<String>> getAllUserIds() async {
    List<String> uids = [];
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      querySnapshot.docs.forEach((doc) {
        uids.add(doc.id);
      });
    } catch (e) {
      //print('Error getting user UIDs: $e');
    }

    return uids;
  }

  static Future<List<UserDetails?>> getAllUsers() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs.map((doc) => UserDetails.fromSnapshot(doc)).toList();
  }

  static Future<String> getName(String? userId) async {
    if (userId == null) {
      return "";
    }
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('UID', isEqualTo: userId).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        if (userDoc.exists && userDoc['name'] != null) {
          return userDoc['name'];
        }
      }
      return "";
    } catch (e) {
      //print('Error retrieving name from Firestore: $e');
      return "";
    }
  }

  static Future<void> updateName(UserDetails user, String newForename, String newSurname) async {
    try {
      await user.reference.update({'forename': newForename});
      await user.reference.update({'surname': newSurname});
    } catch (error) {
      //print("Error updating user's name: $error");
    }
  }

  static Future<void> updateTeam(UserDetails user, String newTeamName) async {
    try {
      String? teamId = await TeamDAO.getTeamId(newTeamName);
      if (teamId != null) await user.reference.update({'team': teamId});
    } catch (error) {
      //print("Error updating user's team: $error");
    }
  }

  static Future<String?> getUserTeam(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userSnapshot['team'] as String?;
    } catch (e) {
      //print('Error retrieving user team: $e');
      return null;
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    } catch (error) {
      //print("Error deleting user: $error");
      throw error;
    }
  }
}
