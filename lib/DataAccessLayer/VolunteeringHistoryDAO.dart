import 'package:HeartOfExperian/Models/LeaderboardStatistic.dart';
import 'package:HeartOfExperian/Models/UserDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/VolunteeringHistory.dart';
import 'UserDAO.dart';

class VolunteeringHistoryDAO {
  static final List<String> volunteeringTypesWithOther = [
    "Other",
    "Education",
    "Environment",
    "Health",
    "Vulnerable communities"
  ];
  static final List<String> volunteeringTypesWithAny = [
    "Any",
    "Education",
    "Environment",
    "Health",
    "Vulnerable communities"
  ];

  static Future<void> addVolunteeringHistory(
      VolunteeringHistory volunteeringHistory) async {
    try {
      await FirebaseFirestore.instance
          .collection('volunteeringHistory')
          .doc()
          .set({
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
    final CollectionReference collection =
        FirebaseFirestore.instance.collection('volunteeringCauses');

    final QuerySnapshot snapshot =
        await collection.where('name', isEqualTo: cause).get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('volunteeringCauses')
          .doc()
          .set({
        'name': cause,
      });
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

      List<MapEntry<String, int>> sortedEntries = volunteeringHoursMap.entries
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      int userRank =
          sortedEntries.indexWhere((entry) => entry.key == userId) + 1;

      return userRank;
    } catch (e) {
      //print('Error retrieving users overall individual rank: $e');
      return 0;
    }
  }

  static Future<int> getUsersVolunteeringHoursOfPastMonth(
      String? userId, String type) async {
    if (userId == null) {
      return 0;
    }
    try {
      DateTime currentDate = DateTime.now();
      DateTime startDateOfPastMonth =
          DateTime(currentDate.year, currentDate.month - 1, 1);

      return getUsersVolunteeringHoursInTimePeriod(
          userId, startDateOfPastMonth, currentDate, type);
    } catch (e) {
      //print('Error retrieving volunteering hours from Firestore: $e');
      return 0;
    }
  }

  static Future<int> getUsersVolunteeringHoursThisFinancialYear(
      String? userId, String type) async {
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

      return getUsersVolunteeringHoursInTimePeriod(
          userId, startDateOfFinancialYear, currentDate, type);
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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringHistory')
          .where('UID', isEqualTo: userId)
          .get();

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

  static Future<int> getUsersVolunteeringHoursInTimePeriod(
      String? userId, DateTime startDate, DateTime endDate, String type) async {
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

  static Future<List<VolunteeringHistory>?> getAllUsersVolunteeringHistory(
      String? userId) async {
    if (userId == null) {
      return null;
    }
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringHistory')
          .where('UID', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => VolunteeringHistory.fromSnapshot(doc))
          .toList();
    } catch (e) {
      //print('Error retrieving volunteering hours from Firestore: $e');
      return null;
    }
  }

  static Future<List<LeaderboardStatistic>> getLeaderboardStatistics(
      DateTime startDate, DateTime endDate, String type) async {
    List<UserDetails?> users = await UserDAO.getAllUsers();
    List<LeaderboardStatistic> leaderboardStatistics = [];

    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    for (UserDetails? user in users) {
      if (user != null) {
        int numVolunteeringHours = await getUsersVolunteeringHoursInTimePeriod(
            user.UID, startDate, endDate, type);

        String userName = (user.UID == currentUser?.uid) ? 'You' : (user.name);

        LeaderboardStatistic leaderboardStatistic = LeaderboardStatistic(
          ID: user.UID,
          name: userName,
          numHours: numVolunteeringHours,
          profilePhotoURL: user.profilePhotoUrl,
          rank: 0,
        );
        leaderboardStatistics.add(leaderboardStatistic);
      }
    }
    leaderboardStatistics.sort((a, b) => b.numHours.compareTo(a.numHours));

    int currentRank = 1;
    for (int i = 0; i < leaderboardStatistics.length; i++) {
      if (i > 0 &&
          leaderboardStatistics[i].numHours !=
              leaderboardStatistics[i - 1].numHours) {
        currentRank = i + 1;
      }
      leaderboardStatistics[i].rank = currentRank;
    }

    return leaderboardStatistics;
  }
}
