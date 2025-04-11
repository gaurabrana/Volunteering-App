import 'package:VolunteeringApp/Models/UserDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/Notification_Model.dart';
import '../Models/VolunteeringHistory.dart';
import '../Pages/common_helper.dart';
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
        'role': volunteeringHistory.role,
        'task': volunteeringHistory.task,
        'date': volunteeringHistory.date,
        'userId': volunteeringHistory.userId,
        'eventId': volunteeringHistory.eventId,
        'organiserId': volunteeringHistory.organiserId,
        'eventName': volunteeringHistory.eventName,
        'userName': volunteeringHistory.userName
      });
      NotificationMessage message = CommonHelper.prepareNotificationBody(
          title: "Work Record Logged",
          body:
              "Your work for event: ${volunteeringHistory.eventName} has been logged by the organiser",
          data: {"id": volunteeringHistory.eventId});

      await CommonHelper.sendNotificationToAssignedUser(
          volunteeringHistory.userId, message);
    } catch (e) {
      print('Error storing volunteering history details: $e');
    }
  }

  static Future<int> getUsersOverallIndividualRank(String? userId) async {
    if (userId == null) {
      return 0;
    }
    try {
      List<UserDetails?> users = await UserDAO().getAllUsers();

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
          DateTime(currentDate.year, currentDate.month, 1);

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
        startDateOfFinancialYear = DateTime(currentDate.year, 4, 1);
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
          .where('userId', isEqualTo: userId)
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
            .where('userId', isEqualTo: userId)
            .where('date', isGreaterThanOrEqualTo: startDate)
            .where('date', isLessThanOrEqualTo: endDate)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('volunteeringHistory')
            .where('userId', isEqualTo: userId)
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

  static Future<List<VolunteeringHistory>> getHistoryByEvent(
      String eventId) async {
    try {
      // Get the collection for volunteering history
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringHistory')
          .where('eventId', isEqualTo: eventId)
          .get();

      // Map the snapshot to a list of VolunteeringHistory objects
      List<VolunteeringHistory> historyList = querySnapshot.docs
          .map((doc) => VolunteeringHistory.fromSnapshot(doc))
          .toList();

      return historyList;
    } catch (e) {
      print('Error fetching volunteering history by event: $e');
      return [];
    }
  }

  static Future<List<VolunteeringHistory>> getHistoryByOrganiser(
      String organiserId) async {
    try {
      // Get the collection for volunteering history
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringHistory')
          .where('organiserId', isEqualTo: organiserId)
          .get();

      // Map the snapshot to a list of VolunteeringHistory objects
      List<VolunteeringHistory> historyList = querySnapshot.docs
          .map((doc) => VolunteeringHistory.fromSnapshot(doc))
          .toList();

      return historyList;
    } catch (e) {
      print('Error fetching volunteering history by organiser: $e');
      return [];
    }
  }

  static Future<List<VolunteeringHistory>> getHistoryByEventAndUser(
      String eventId, String userId) async {
    try {
      // Get the collection for volunteering history
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteeringHistory')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      // Map the snapshot to a list of VolunteeringHistory objects
      List<VolunteeringHistory> historyList = querySnapshot.docs
          .map((doc) => VolunteeringHistory.fromSnapshot(doc))
          .toList();

      return historyList;
    } catch (e) {
      print('Error fetching volunteering history by event: $e');
      return [];
    }
  }
}
