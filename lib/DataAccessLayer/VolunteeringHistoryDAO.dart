import 'package:HeartOfExperian/DataAccessLayer/PhotoDAO.dart';
import 'package:HeartOfExperian/Models/LeaderboardStatistic.dart';
import 'package:HeartOfExperian/Models/UserDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/Team.dart';
import '../Models/VolunteeringHistory.dart';
import 'TeamDAO.dart';
import 'UserDAO.dart';

class VolunteeringHistoryDAO {
  static final List<String> volunteeringTypesWithOther = ["Other", "Education", "Environment", "Health", "Vulnerable communities"];
  static final List<String> volunteeringTypesWithAny = ["Any", "Education", "Environment", "Health", "Vulnerable communities"];

  static Future<void> addVolunteeringHistory(VolunteeringHistory volunteeringHistory) async {
    try {
      await FirebaseFirestore.instance.collection('volunteeringHistory').doc().set({
        'hours': volunteeringHistory.hours,
        'minutes': volunteeringHistory.minutes,
        'type': volunteeringHistory.type,
        'cause': volunteeringHistory.cause,
        'date': volunteeringHistory.date,
        'UID': volunteeringHistory.UID,
      });
      await addCauseIfNotExists(volunteeringHistory.cause);
    } catch (e) {
      //print('Error storing volunteering history details: $e');
    }
  }

  static Future<void> addCauseIfNotExists(String cause) async {
    final CollectionReference collection = FirebaseFirestore.instance.collection('volunteeringCauses');

    final QuerySnapshot snapshot = await collection.where('name', isEqualTo: cause).get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('volunteeringCauses').doc().set({
        'name': cause,
      });
    }
  }

  static Future<int> getUsersTeamsRank(String? userId) async {
    if (userId == null) {
      return 0;
    }

    try {
      UserDetails? currentUser = await UserDAO.getUserDetails(userId);
      if (currentUser == null || currentUser.team == null) {
        return 0;
      }
      String userTeamId = currentUser.team!;

      List<Team?> teams = await TeamDAO.getAllTeams();

      Map<String, int> teamVolunteeringHoursMap = {};
      for (Team? team in teams) {
        if (team != null) {
          int totalHours = await getTeamsAllTimeVolunteeringHours(team.reference.id);
          teamVolunteeringHoursMap[team.reference.id] = totalHours;
        }
      }

      List<MapEntry<String, int>> sortedEntries = teamVolunteeringHoursMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      int currentRank = 1;
      int previousHours = -1;
      int teamRank = 0;
      for (var entry in sortedEntries) {
        if (entry.value != previousHours) {
          teamRank = currentRank;
        }
        if (entry.key == userTeamId) {
          return teamRank;
        }
        currentRank++;
        previousHours = entry.value;
      }

      return 0;
    } catch (e) {
      //print('Error retrieving user\'s team rank: $e');
      return 0;
    }
  }

  static Future<int> getTeamsAllTimeVolunteeringHours(String userTeamId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('volunteeringHistory').get();

      int totalHours = 0;
      for (DocumentSnapshot doc in querySnapshot.docs) {
        String uid = doc['UID'] as String;
        int hours = doc['hours'] as int;
        int minutes = doc['minutes'] as int;
        String? teamId = await UserDAO.getUserTeam(uid);
        if (teamId == userTeamId) {
          totalHours += (hours * 60) + minutes;
        }
      }
      return totalHours ~/ 60; // Convert total minutes to hours
    } catch (e) {
      //print('Error retrieving team\'s volunteering hours: $e');
      return 0;
    }
  }

  static Future<int> getUsersOverallIndividualRank(String? userId) async {
    if (userId == null) {
      return 0;
    }
    try {
      List<UserDetails?> users = await UserDAO.getAllUsers();

      Map<String, int> volunteeringHoursMap = {};
      for (UserDetails? user in users) {
        if (user != null) {
          int totalHours = await getUsersAllTimeVolunteeringHours(user.UID);
          volunteeringHoursMap[user.UID] = totalHours;
        }
      }

      List<MapEntry<String, int>> sortedEntries = volunteeringHoursMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      int userRank = sortedEntries.indexWhere((entry) => entry.key == userId) + 1;

      return userRank;
    } catch (e) {
      //print('Error retrieving users overall individual rank: $e');
      return 0;
    }
  }

  static Future<int> getUsersTeamIndividualRank(String? userId) async {
    if (userId == null) {
      return 0;
    }
    try {
      UserDetails? currentUser = await UserDAO.getUserDetails(userId);
      if (currentUser == null || currentUser.team == null) {
        return 0;
      }
      String userTeamId = currentUser.team!;

      List<UserDetails?> teamMembers = await UserDAO.getTeamMembers(userTeamId);

      Map<String, int> volunteeringHoursMap = {};
      for (UserDetails? user in teamMembers) {
        if (user != null) {
          int totalHours = await getUsersAllTimeVolunteeringHours(user.UID);
          volunteeringHoursMap[user.UID] = totalHours;
        }
      }

      List<MapEntry<String, int>> sortedEntries = volunteeringHoursMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      int userRank = sortedEntries.indexWhere((entry) => entry.key == userId) + 1;

      return userRank;
    } catch (e) {
      //print('Error retrieving user\'s team individual rank: $e');
      return 0;
    }
  }

  static Future<int> getUsersVolunteeringHoursOfPastMonth(String? userId, String type) async {
    if (userId == null) {
      return 0;
    }
    try {
      DateTime currentDate = DateTime.now();
      DateTime startDateOfPastMonth = DateTime(currentDate.year, currentDate.month - 1, 1);

      return getUsersVolunteeringHoursInTimePeriod(userId, startDateOfPastMonth, currentDate, type);
    } catch (e) {
      //print('Error retrieving volunteering hours from Firestore: $e');
      return 0;
    }
  }

  static Future<int> getUsersVolunteeringHoursThisFinancialYear(String? userId, String type) async {
    if (userId == null) {
      return 0;
    }
    try {
      DateTime currentDate = DateTime.now();
      DateTime startDateOfFinancialYear;
      if (currentDate.month >= 4) {
        startDateOfFinancialYear = DateTime(currentDate.year, 4, 1);
      } else {
        startDateOfFinancialYear = DateTime(currentDate.year - 1, 4, 1);
      }

      return getUsersVolunteeringHoursInTimePeriod(userId, startDateOfFinancialYear, currentDate, type);
    } catch (e) {
      //print('Error retrieving volunteering hours from Firestore: $e');
      return 0;
    }
  }

  static Future<int> getUsersAllTimeVolunteeringHours(String? userId) async {
    if (userId == null) {
      return 0;
    }
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('volunteeringHistory').where('UID', isEqualTo: userId).get();

      int totalMinutes = 0;
      for (DocumentSnapshot doc in querySnapshot.docs) {
        int hours = doc['hours'] as int;
        int minutes = doc['minutes'] as int;
        totalMinutes += (hours * 60) + minutes;
      }
      int totalHours = totalMinutes ~/ 60;
      return totalHours;
    } catch (e) {
      //print('Error retrieving volunteering hours from Firestore: $e');
      return 0;
    }
  }

  static Future<int> getUsersVolunteeringHoursInTimePeriod(String? userId, DateTime startDate, DateTime endDate, String type) async {
    if (userId == null) {
      return 0;
    }
    try {
      late QuerySnapshot querySnapshot;

      if (type == "Any") {
        querySnapshot = await FirebaseFirestore.instance
            .collection('volunteeringHistory')
            .where('UID', isEqualTo: userId)
            .where('date', isGreaterThanOrEqualTo: startDate)
            .where('date', isLessThanOrEqualTo: endDate)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('volunteeringHistory')
            .where('UID', isEqualTo: userId)
            .where('date', isGreaterThanOrEqualTo: startDate)
            .where('date', isLessThanOrEqualTo: endDate)
            .where('type', isEqualTo: type)
            .get();
      }

      int totalMinutes = 0;
      for (DocumentSnapshot doc in querySnapshot.docs) {
        int hours = doc['hours'] as int;
        int minutes = doc['minutes'] as int;
        totalMinutes += (hours * 60) + minutes;
      }
      int totalHours = totalMinutes ~/ 60;
      return totalHours;
    } catch (e) {
      //print('Error retrieving volunteering hours from Firestore: $e');
      return 0;
    }
  }

  static Future<int> getTeamsVolunteeringHoursInTimePeriod(DocumentReference teamReference, DateTime startDate, DateTime endDate, String type) async {
    int totalHours = 0;
    try {
      List<UserDetails?> teamMembers = await UserDAO.getTeamMembers(teamReference.id);

      for (var user in teamMembers) {
        if (user != null) {
          totalHours += await getUsersVolunteeringHoursInTimePeriod(user.UID, startDate, endDate, type);
        }
      }
    } catch (e) {
      //print('Error retrieving volunteering hours from Firestore: $e');
      return 0;
    }
    return totalHours;
  }

  static Future<List<VolunteeringHistory>?> getAllUsersVolunteeringHistory(String? userId) async {
    if (userId == null) {
      return null;
    }
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('volunteeringHistory').where('UID', isEqualTo: userId).get();

      return querySnapshot.docs.map((doc) => VolunteeringHistory.fromSnapshot(doc)).toList();
    } catch (e) {
      //print('Error retrieving volunteering hours from Firestore: $e');
      return null;
    }
  }

  static Future<List<LeaderboardStatistic>> getLeaderboardStatistics(DateTime startDate, DateTime endDate, String type) async {
    List<UserDetails?> users = await UserDAO.getAllUsers();
    List<LeaderboardStatistic> leaderboardStatistics = [];

    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    for (UserDetails? user in users) {
      if (user != null) {
        int numVolunteeringHours = await getUsersVolunteeringHoursInTimePeriod(user.UID, startDate, endDate, type);

        String userName = (user.UID == currentUser?.uid) ? 'You' : (user.forename + " " + user.surname);

        LeaderboardStatistic leaderboardStatistic = LeaderboardStatistic(
          ID: user.UID,
          name: userName,
          numHours: numVolunteeringHours,
          profilePhotoURL: user.profilePhotoUrl,
          teamId: user.team,
          rank: 0,
        );
        leaderboardStatistics.add(leaderboardStatistic);
      }
    }
    leaderboardStatistics.sort((a, b) => b.numHours.compareTo(a.numHours));

    int currentRank = 1;
    for (int i = 0; i < leaderboardStatistics.length; i++) {
      if (i > 0 && leaderboardStatistics[i].numHours != leaderboardStatistics[i - 1].numHours) {
        currentRank = i + 1;
      }
      leaderboardStatistics[i].rank = currentRank;
    }

    return leaderboardStatistics;
  }

  static Future<List<LeaderboardStatistic>> getLeaderboardStatisticsWithinTeam(
      DateTime startDate, DateTime endDate, String type, List<UserDetails?> teamMembers) async {
    List<LeaderboardStatistic> leaderboardStatistics = [];

    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    for (UserDetails? user in teamMembers) {
      if (user != null) {
        int numVolunteeringHours = await getUsersVolunteeringHoursInTimePeriod(user.UID, startDate, endDate, type);

        String userName = (user.UID == currentUser?.uid) ? 'You' : (user.forename + " " + user.surname);

        LeaderboardStatistic leaderboardStatistic = LeaderboardStatistic(
          ID: user.UID,
          name: userName,
          numHours: numVolunteeringHours,
          profilePhotoURL: user.profilePhotoUrl,
          teamId: user.team,
          rank: 0,
        );
        leaderboardStatistics.add(leaderboardStatistic);
      }
    }
    leaderboardStatistics.sort((a, b) => b.numHours.compareTo(a.numHours));

    int currentRank = 1;
    for (int i = 0; i < leaderboardStatistics.length; i++) {
      if (i > 0 && leaderboardStatistics[i].numHours != leaderboardStatistics[i - 1].numHours) {
        currentRank = i + 1;
      }
      leaderboardStatistics[i].rank = currentRank;
    }

    return leaderboardStatistics;
  }

  static Future<List<LeaderboardStatistic>> getLeaderboardStatisticsWithinTeamUsingTeamId(
      DateTime startDate, DateTime endDate, String type, String teamId) async {
    List<UserDetails?> teamMembers = await UserDAO.getTeamMembers(teamId);

    List<LeaderboardStatistic> leaderboardStatistics = [];

    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    for (UserDetails? user in teamMembers) {
      if (user != null) {
        int numVolunteeringHours = await getUsersVolunteeringHoursInTimePeriod(user.UID, startDate, endDate, type);

        String userName = (user.UID == currentUser?.uid) ? 'You' : (user.forename + " " + user.surname);

        LeaderboardStatistic leaderboardStatistic = LeaderboardStatistic(
          ID: user.UID,
          name: userName,
          numHours: numVolunteeringHours,
          profilePhotoURL: user.profilePhotoUrl,
          teamId: user.team,
          rank: 0,
        );
        leaderboardStatistics.add(leaderboardStatistic);
      }
    }
    leaderboardStatistics.sort((a, b) => b.numHours.compareTo(a.numHours));

    int currentRank = 1;
    for (int i = 0; i < leaderboardStatistics.length; i++) {
      if (i > 0 && leaderboardStatistics[i].numHours != leaderboardStatistics[i - 1].numHours) {
        currentRank = i + 1;
      }
      leaderboardStatistics[i].rank = currentRank;
    }

    return leaderboardStatistics;
  }

  static Future<List<LeaderboardStatistic>> getTeamLeaderboardStatistics(DateTime startDate, DateTime endDate, String type) async {
    List<Team?> teams = await TeamDAO.getAllTeams();
    List<LeaderboardStatistic> leaderboardStatistics = [];

    for (Team? team in teams) {
      if (team != null) {
        int numVolunteeringHours = await getTeamsVolunteeringHoursInTimePeriod(team.reference, startDate, endDate, type);

        LeaderboardStatistic leaderboardStatistic = LeaderboardStatistic(
          ID: team.reference.id,
          name: team.name,
          numHours: numVolunteeringHours,
          profilePhotoURL: team.profilePhotoUrl ?? PhotoDAO.teamDefaultProfilePictureURL,
          teamId: team.reference.id,
          rank: 0,
        );
        leaderboardStatistics.add(leaderboardStatistic);
      }
    }
    leaderboardStatistics.sort((a, b) => b.numHours.compareTo(a.numHours));

    int currentRank = 1;
    for (int i = 0; i < leaderboardStatistics.length; i++) {
      if (i > 0 && leaderboardStatistics[i].numHours != leaderboardStatistics[i - 1].numHours) {
        currentRank = i + 1;
      }
      leaderboardStatistics[i].rank = currentRank;
    }

    return leaderboardStatistics;
  }
}
