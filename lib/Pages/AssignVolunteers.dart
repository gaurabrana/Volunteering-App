import 'package:HeartOfExperian/Models/UserDetails.dart';
import 'package:HeartOfExperian/Models/VolunteeringEvent.dart';
import 'package:HeartOfExperian/Pages/RecordVolunteering.dart';
import 'package:HeartOfExperian/Pages/common_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../DataAccessLayer/UserDAO.dart';
import '../DataAccessLayer/VolunteeringEventRegistrationsDAO.dart';
import '../Models/VolunteeringEventRegistration.dart';

class Assignvolunteers extends StatefulWidget {
  final VolunteeringEvent event;
  const Assignvolunteers({super.key, required this.event});

  @override
  State<Assignvolunteers> createState() => _AssignvolunteersState();
}

class _AssignvolunteersState extends State<Assignvolunteers> {
  List<VolunteeringEventRegistration> registrations = [];
  Map<String, UserDetails?> userInfo = {};
  Map<String, DateTime?> startDates = {};
  Map<String, DateTime?> endDates = {};
  bool isLoading = true;
  Map<String, bool> assignedUsers = {}; // Track assigned users

  @override
  void initState() {
    super.initState();
    loadUserIds();
  }

  Future<void> loadUserIds() async {
    registrations =
        await VolunteeringEventRegistrationsDAO.getAllUserIdsForEvent(
            widget.event.reference.id);
    for (var registration in registrations) {
      assignedUsers[registration.userId] = registration.isAssigned;
      UserDetails? attendee = await UserDAO.getUserDetails(registration.userId);
      if (attendee != null) {
        userInfo[attendee.UID] = attendee;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> assignVolunteer(String userId) async {
    final start = startDates[userId];
    final end = endDates[userId];

    if (start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill start and end date')),
      );
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('volunteeringEventRegistrations')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: widget.event.reference.id)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'isAssigned': true,
          'assignedStartDate': start,
          'assignedEndDate': end,
        });

        // ✅ Update local state
        setState(() {
          assignedUsers[userId] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Volunteer assigned')),
        );

        await CommonHelper.sendNotificationToAssignedUser(
            userId, widget.event.reference.id);
      }
    } catch (e) {
      print('Error assigning volunteer: $e');
    }
  }

  Future<void> removeVolunteer(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('volunteeringEventRegistrations')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: widget.event.reference.id)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'isAssigned': false,
          'assignedStartDate': null,
          'assignedEndDate': null,
        });

        // Optional: Clear the local state if needed
        setState(() {
          startDates.remove(userId);
          endDates.remove(userId);
          assignedUsers[userId] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User removed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No registration found for this user')),
        );
      }
    } catch (e) {
      print('Error removing volunteer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing user')),
      );
    }
  }

  Future<void> pickDate(String userId, bool isStart) async {
    DateTime eventDate = widget.event.date;

    DateTime initialDate =
        DateTime.now().isBefore(eventDate) ? eventDate : DateTime.now();
    DateTime firstDate = eventDate;

    // If picking end date, make sure it's after the selected start date
    if (!isStart && startDates[userId] != null) {
      firstDate = startDates[userId]!.add(Duration(days: 1));
      initialDate = firstDate;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDates[userId] = picked;
          // Optional: Reset end date if it's before new start date
          if (endDates[userId] != null && picked.isAfter(endDates[userId]!)) {
            endDates[userId] = null;
          }
        } else {
          endDates[userId] = picked;
        }
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Date';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign & Track Volunteers')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: registrations.length,
              itemBuilder: (context, index) {
                final registration = registrations[index];
                final user = userInfo[registration.userId];
                final uid = user!.UID;

                // Pre-fill dates and role if not already set
                startDates[uid] ??= registration.assignedStartDate;
                endDates[uid] ??= registration.assignedEndDate;

                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: user.profilePhotoUrl.isNotEmpty
                                  ? NetworkImage(user.profilePhotoUrl)
                                  : null,
                              child: user.profilePhotoUrl.isEmpty
                                  ? Icon(Icons.person)
                                  : null,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(user.email,
                                      style:
                                          TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 35,
                          child: OutlinedButton(
                            onPressed: () => pickDate(uid, true),
                            child: Text(
                              'Start: ${formatDate(startDates[uid])}',
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 35,
                          child: OutlinedButton(
                            onPressed: () => pickDate(uid, false),
                            child: Text('End: ${formatDate(endDates[uid])}'),
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (assignedUsers[user.UID] == false) SizedBox(),
                            if (assignedUsers[user.UID] == true)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          RecordVolunteeringPage(
                                            eventId: widget.event.reference.id,
                                            userId: user.UID,
                                            event: widget.event,
                                            registration: registration,
                                            userName: user.name,
                                          )));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                child: Text(
                                  'Track',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ElevatedButton(
                              onPressed: () {
                                if (assignedUsers[user.UID] == true) {
                                  removeVolunteer(uid);
                                } else {
                                  assignVolunteer(uid);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: assignedUsers[user.UID] == true
                                    ? Colors.red
                                    : Theme.of(context).primaryColor,
                              ),
                              child: Text(
                                assignedUsers[user.UID] == true
                                    ? 'Remove'
                                    : 'Assign',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
