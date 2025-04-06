import 'package:flutter/material.dart';

import '../Models/VolunteeringEvent.dart';
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

class CommonWidget {
  // Helper method to build each event card
  static Widget buildEventCard(VolunteeringEvent event, BuildContext context) {
    Color? statusColor;
    String? statusText;

    if (event.currentUserRegistration != null) {
      if (event.currentUserRegistration!.isAssigned) {
        statusColor = Colors.green;
        statusText = "Assigned";
      } else {
        statusColor = Colors.orange;
        statusText = "Applied";
      }
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      event.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${event.date.toLocal().toString().split(' ')[0]} at ${event.location}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
              if (statusText != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
