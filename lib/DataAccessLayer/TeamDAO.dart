import 'package:HeartOfExperian/DataAccessLayer/PhotoDAO.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Team.dart';

class TeamDAO {
  static Future<String?> getTeamName(String teamId) async {
    try {
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();

      if (teamSnapshot.exists) {
        Map<String, dynamic>? data = teamSnapshot.data() as Map<String, dynamic>?;
        return data?['name'];
      } else {
        //print('Team with ID $teamId not found');
        return null;
      }
    } catch (e) {
      //print('Error retrieving team name: $e');
      return null;
    }
  }

  static Future<String?> getTeamId(String teamName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('teams').where('name', isEqualTo: teamName).get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        //print('Team with name $teamName not found');
        return null;
      }
    } catch (error) {
      //print('Error getting team ID: $error');
      return null;
    }
  }

  static Future<void> updateName(String teamId, String newName) async {
    try {
      QuerySnapshot teamsQuerySnapshot = await FirebaseFirestore.instance.collection('teams').where(FieldPath.documentId, isEqualTo: teamId).get();

      if (teamsQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot teamSnapshot = teamsQuerySnapshot.docs.first;
        await teamSnapshot.reference.update({'name': newName});
      } else {
        //print('Team with ID $teamId not found');
        return;
      }
    } catch (error) {
      //print("Error updating team name: $error");
    }
  }

  static Future<bool> isUserInTeam(String userId, String teamId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (querySnapshot.exists) {
        Map<String, dynamic> userData = querySnapshot.data() as Map<String, dynamic>;
        String? userTeam = userData['team'];
        return userTeam == teamId;
      } else {
        //print('User with ID $userId not found');
        return false;
      }
    } catch (error) {
      //print("Error checking if user is in team: $error");
      return false;
    }
  }

  static Future<String> addNewTeam(String teamName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('teams').where('name', isEqualTo: teamName).get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('teams').doc().set({
          'name': teamName,
          'profilePhotoUrl': PhotoDAO.teamDefaultProfilePictureURL,
        });
        return "";
      } else {
        return ('Team with name $teamName already exists');
      }
    } catch (e) {
      //print('Error storing team details: $e');
    }
    return "Error storing team details";
  }

  static Future<List<Team>> getAllTeams() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('teams').get();
    return querySnapshot.docs.map((doc) => Team.fromSnapshot(doc)).toList();
  }

  static Future<List<String>> getAllTeamNames() async {
    try {
      final List<String> teamNames = [];

      await FirebaseFirestore.instance.collection('teams').get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          final team = Team.fromSnapshot(doc);
          teamNames.add(team.name);
        });
      });

      return teamNames;
    } catch (e) {
      //print('Error getting team names: $e');
      return [];
    }
  }
}
