import 'package:VolunteeringApp/DataAccessLayer/VolunteeringEventDAO.dart';
import 'package:VolunteeringApp/Models/VolunteeringEvent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'RecordVolunteering.dart';
import 'VolunteeringEventDetails.dart';
import 'common_helper.dart';

class VolunteerAssignandTrack extends StatefulWidget {
  const VolunteerAssignandTrack({super.key});

  @override
  State<VolunteerAssignandTrack> createState() =>
      _VolunteerAssignandTrackState();
}

class _VolunteerAssignandTrackState extends State<VolunteerAssignandTrack> {
  late List<VolunteeringEvent> organiserEvents = [];

  @override
  void initState() {
    getOrganiserEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your Events', style: TextStyle(fontSize: 24)),
      ),
      body: Column(
        children: [
          Center(
            child: Text(
              'Select event you want to manage',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: buildEventList(),
            ),
          ),
        ],
      ),
    );
  }

  void getOrganiserEvents() async {
    var events = await VolunteeringEventDAO().getEventsByOrganiserUID(
        FirebaseAuth.instance.currentUser!.uid);
    if (events != null) {
      setState(() {
        organiserEvents = events;
      });
    }
  }

  // Helper method to display events in a list
  Widget buildEventList() {
    return Column(
      children: organiserEvents.map((event) {
        return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    VolunteeringEventDetailsPage(volunteeringEvent: event),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CommonWidget.buildEventCard(event, context),
            ));
      }).toList(),
    );
  }
}
