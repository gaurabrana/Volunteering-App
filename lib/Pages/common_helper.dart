import 'package:flutter/material.dart';

import 'Leaderboard.dart';
import 'NavBarManager.dart';
import 'RecordVolunteering.dart';
import 'SearchVolunteering.dart';
import 'homepage.dart';

class CommonHelper {
  static void redirectToAnotherPage(
      {required int indexToNavigate,
      required GlobalKey<NavigatorState> mainNavigatorKey,
      required GlobalKey<NavigatorState> logInNavigatorKey,
      required BuildContext context}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NavBarManager(
          initialIndex: indexToNavigate,
          searchVolunteeringPage: SearchVolunteeringPage(),
          feedPage: Homepage(
            mainNavigatorKey: mainNavigatorKey,
            logInNavigatorKey: logInNavigatorKey,
          ),
          recordVolunteeringPage: RecordVolunteeringPage(),
          leaderboardPage: LeaderboardPage(),
          mainNavigatorKey: mainNavigatorKey,
          logInNavigatorKey: logInNavigatorKey,
        ),
      ),
    );
  }

  static bool isFutureDate(DateTime date) {
    // Get the current date and time
    DateTime currentDateTime = DateTime.now();

    // Check if _date is in the future
    return date.isAfter(currentDateTime);
  }
}
