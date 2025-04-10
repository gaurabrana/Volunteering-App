import 'package:HeartOfExperian/DataAccessLayer/VolunteeringEventFavouritesDAO.dart';
import 'package:HeartOfExperian/Pages/Attendees.dart';
import 'package:HeartOfExperian/Pages/ColleagueProfile.dart';
import 'package:HeartOfExperian/Pages/CustomWidgets/EventLocationMap.dart';
import 'package:HeartOfExperian/Pages/Settings/SharedPreferences.dart';
import 'package:HeartOfExperian/Pages/common_helper.dart';
import 'package:HeartOfExperian/Pages/review_rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../DataAccessLayer/UserDAO.dart';
import '../DataAccessLayer/VolunteeringEventRegistrationsDAO.dart';
import '../Models/Notification_Model.dart';
import '../Models/UserDetails.dart';
import '../Models/VolunteeringEvent.dart';
import '../Models/VolunteeringEventFavourite.dart';
import '../Models/VolunteeringEventRegistration.dart';
import '../constants/enums.dart';
import 'AssignVolunteers.dart';
import 'CustomWidgets/BackButton.dart';

class VolunteeringEventDetailsPage extends StatefulWidget {
  final VolunteeringEvent volunteeringEvent;

  const VolunteeringEventDetailsPage(
      {super.key, required this.volunteeringEvent});

  @override
  State<StatefulWidget> createState() => VolunteeringEventDetailsPageState();
}

class VolunteeringEventDetailsPageState
    extends State<VolunteeringEventDetailsPage> {
  bool areOrganiserDetailsLoading = true;
  late UserDetails _organiserDetails;
  late List<UserDetails> _attendees;
  int _selectedIndex = 0;
  bool _registrationInProgress = false;
  bool areAttendeeDetailsLoading = true;
  late bool isUserRegistered;
  late bool isFavourite;
  bool isFavouriteLoading = true;
  bool isCurrentUserOwner = false;
  bool isCurrentUserAnOrganisation = false;
  List<VolunteeringEventRegistration> attendeesList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchOrganiserDetails();
    await fetchAttendees();
    await fetchIsFavourite();
  }

  Future<void> fetchOrganiserDetails() async {
    try {
      UserDetails? userDetails =
          await UserDAO().getUserDetails(widget.volunteeringEvent.organiserUID);

      UserDetails? detail =
          await SignInSharedPreferences().getCurrentUserDetails();
      if (detail != null) {
        isCurrentUserAnOrganisation = detail.role == UserRole.organisation;
      }
      setState(() {
        _organiserDetails = userDetails!;
        isCurrentUserOwner =
            userDetails.UID == FirebaseAuth.instance.currentUser!.uid;
        areOrganiserDetailsLoading = false;
      });
    } catch (e) {
      //print('Error fetching organiser user details: $e');
    }
  }

  Future<void> fetchAttendees() async {
    try {
      List<UserDetails> attendees = [];
      attendeesList =
          await VolunteeringEventRegistrationsDAO().getAllUserIdsForEvent(
              widget.volunteeringEvent.reference!.id);
      List<String> attendeeIds = attendeesList.map((e) => e.userId).toList();
      if (attendeeIds.contains(FirebaseAuth.instance.currentUser!.uid)) {
        setState(() {
          isUserRegistered = true;
          //print('user already registered');
        });
      } else {
        setState(() {
          isUserRegistered = false;
          //print('user not already registered');
        });
      }

      for (var id in attendeeIds) {
        UserDetails? attendee = await UserDAO().getUserDetails(id);
        if (attendee != null) {
          attendees.add(attendee);
        }
      }
      setState(() {
        _attendees = attendees;
        areAttendeeDetailsLoading = false;
      });
    } catch (e) {
      //print('Error fetching attendees: $e');
    }
  }

  Future<void> fetchIsFavourite() async {
    try {
      bool favourite =
          await VolunteeringEventFavouritesDAO.isEventFavouritedByUser(
              FirebaseAuth.instance.currentUser!.uid,
              widget.volunteeringEvent.reference!.id);

      setState(() {
        isFavourite = favourite;
        isFavouriteLoading = false;
      });
    } catch (e) {
      //print('Error fetching favourite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
          padding:
              const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GoBackButton(),
                          buildTitle(),
                          buildFavouriteButton(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      buildLocation(),
                      const SizedBox(height: 25),
                      buildDate(),
                      const SizedBox(height: 20),
                      buildOrganiser(),
                      const SizedBox(height: 20),
                      buildAttendeesList(),
                      const SizedBox(height: 20),
                      buildTabBar(),
                      const SizedBox(height: 20),
                      buildTabBody(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 20),
                  !areAttendeeDetailsLoading
                      ? isCurrentUserOwner
                          ? buildOrganiserButton()
                          : buildRegisterButton(context)
                      : const CircularProgressIndicator()
                ],
              ),
            ],
          )),
    );
  }

  Widget buildTitle() {
    return Flexible(
      child: Text(
        widget.volunteeringEvent.name,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        maxLines: 2,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          decorationColor: Colors.black,
        ),
      ),
    );
  }

  Widget buildFavouriteButton() {
    return isFavouriteLoading
        ? const CircularProgressIndicator()
        : IconButton(
            onPressed: () {
              setState(() {
                isFavourite = !isFavourite;
                isFavouriteLoading = true;
              });
              if (isFavourite) {
                VolunteeringEventFavourite volunteeringEventFavourite =
                    VolunteeringEventFavourite(
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        eventId: widget.volunteeringEvent.reference!.id);
                VolunteeringEventFavouritesDAO.addVolunteeringEventFavourite(
                    volunteeringEventFavourite);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Added to favourites successfully'),
                ));
              } else {
                VolunteeringEventFavouritesDAO.removeVolunteeringEventFavourite(
                    FirebaseAuth.instance.currentUser!.uid,
                    widget.volunteeringEvent.reference!.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Removed from favourites successfully'),
                ));
              }
              setState(() {
                isFavouriteLoading = false;
              });
            },
            icon: isFavourite
                ? const FaIcon(FontAwesomeIcons.solidHeart,
                    color: Colors.red, size: 30)
                : const FaIcon(FontAwesomeIcons.heart,
                    color: Colors.red, size: 30), // todo click to favourite
          );
  }

  Widget buildLocation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 9),
        Icon(Icons.location_on_rounded, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 21),
        Text(
          widget.volunteeringEvent.location,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget buildDate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 9),
        Icon(Icons.calendar_month, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 21),
        Text(
          "${DateFormat('EEEE, d\'th\' MMMM yyyy').format(widget.volunteeringEvent.date)}",
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget buildOrganiser() {
    return areOrganiserDetailsLoading
        ? const CircularProgressIndicator()
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 4),
              Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(_organiserDetails.profilePhotoUrl),
                    ),
                  )),
              const SizedBox(width: 10),
              Text(
                "Organised by ",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ColleagueProfilePage(UID: _organiserDetails.UID),
                  ));
                },
                child: Text(
                  _organiserDetails.name,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          );
  }

  Widget buildAttendeesList() {
    VolunteeringEventRegistration? info = attendeesList.isEmpty
        ? null
        : attendeesList.firstWhereOrNull(
            (element) =>
                element.userId == FirebaseAuth.instance.currentUser!.uid &&
                element.isAssigned,
          );

    return !areOrganiserDetailsLoading
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // if assigned show details
              // role, start and end
              if (info != null && !isCurrentUserOwner)
                Row(
                  children: [
                    Icon(Icons.assignment_turned_in_outlined),
                    buildAssignedInformation(info!),
                  ],
                ),

              TextButton(
                child: Row(
                  children: [
                    Icon(Icons.group),
                    SizedBox(
                      width: 8,
                    ),
                    const Text('View all'),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => AttendeesPage(
                              users: _attendees,
                              event: widget.volunteeringEvent,
                            )),
                  );
                },
              ),
              if (isCurrentUserAnOrganisation && isCurrentUserOwner)
                TextButton(
                  child: Row(
                    children: [
                      Icon(Icons.notification_add),
                      SizedBox(
                        width: 8,
                      ),
                      const Text('Notify Volunteers'),
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController inputController =
                            TextEditingController();

                        return AlertDialog(
                          title: const Text('Send Notification'),
                          content: TextField(
                            controller: inputController,
                            decoration: const InputDecoration(
                              labelText: 'Enter your message',
                              hintText: 'Type your notification here',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final input = inputController.text.trim();
                                if (input.isNotEmpty) {
                                  sendNotification(
                                      input); // Call your function with the input
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                } else {
                                  // Optionally, show a validation message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter a message'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Send'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
            ],
          )
        : SizedBox();
  }

  sendNotification(String organiserMessage) async {
    // Prepare the notification body
    NotificationMessage message = CommonHelper.prepareNotificationBody(
      title: "Event Notification",
      body:
          "Event ${widget.volunteeringEvent.name} organised by ${_organiserDetails.name} has notified all assigned volunteers. The notice is: $organiserMessage",
      data: {"id": widget.volunteeringEvent.reference!.id},
    );

    // Show progress dialog
    int completed = 0;
    int total = _attendees.length;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal
      builder: (context) {
        return AlertDialog(
          title: Text("Sending Notifications"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Sending notifications to volunteers..."),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: total > 0 ? completed / total : null,
                  ),
                  SizedBox(height: 10),
                  Text("$completed of $total notifications sent."),
                ],
              );
            },
          ),
        );
      },
    );

    // Iterate through attendees and send notifications
    for (var element in _attendees) {
      String id = element.UID;
      try {
        await CommonHelper.sendNotificationToAssignedUser(id, message);
        completed++;
      } catch (e) {
        print('Failed to send notification to user $id: $e');
      }

      // Update dialog progress
      (context as Element).markNeedsBuild();
    }

    // Close the dialog after completion
    Navigator.of(context, rootNavigator: true).pop();

    // Show completion message
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Notifications Sent"),
          content: Text(
              "Successfully sent notifications to $completed out of $total volunteers."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget buildTabBar() {
//todo make pretty
    Widget buildTabItem(int index, String title) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
                color:
                    _selectedIndex == index ? Colors.blue : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _selectedIndex == index ? Colors.blue : Colors.grey,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildTabItem(0, 'Details'),
        buildTabItem(1, 'Location'),
        buildTabItem(2, 'Contact'),
      ],
    );
  }

  Widget buildTabBody() {
    if (_selectedIndex == 0) {
      return buildDescriptionDetails();
    } else if (_selectedIndex == 1) {
      return buildLocationDetails();
    }
    return (widget.volunteeringEvent.organiserContactConsent)
        ? buildContactDetails()
        : const Text(
            'The organiser has opted out of receiving event-related inquiries.');
  }

  Widget buildDescriptionDetails() {
    return Column(children: [
      Text(widget.volunteeringEvent.description.replaceAll("\\n", "\n")),
      const SizedBox(height: 15),
      widget.volunteeringEvent.website.isNotEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.globe,
                    color: Colors.grey.shade500, size: 17),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () async {
                    try {
                      Uri uri = Uri.parse(widget.volunteeringEvent.website);
                      await launchUrl(uri);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Unable to open webpage'),
                      ));
                    }
                  },
                  child: Text(
                    widget.volunteeringEvent.website,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            )
          : Container()
    ]);
  }

  Widget buildLocationDetails() {
    return !widget.volunteeringEvent.online
        ? Column(children: [
            Row(children: [
              Text(widget.volunteeringEvent.location),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.content_copy, size: 15),
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.volunteeringEvent.location));
                },
              ),
            ]),
            EventLocationMap(
                eventLocation: new LatLng(widget.volunteeringEvent.latitude,
                    widget.volunteeringEvent.longitude)),
          ])
        : const Text("Online");
  }

  Widget buildContactDetails() {
    return areOrganiserDetailsLoading
        ? const CircularProgressIndicator()
        : Row(children: [
            Container(
                width: 280,
                height: 80,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 10,
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ColleagueProfilePage(UID: _organiserDetails.UID),
                      ));
                    },
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          _organiserDetails.profilePhotoUrl,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        _organiserDetails.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      subtitle: Text(
                        _organiserDetails.email.toLowerCase(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      //trailing: Container() // todo this will be msg button eventually
                    ),
                  ),
                )),
            SizedBox(width: 10),
          ]);
  }

  Widget buildRegisterButton(BuildContext context) {
    VolunteeringEventRegistration? info = attendeesList.firstWhereOrNull(
        (element) => element.userId == FirebaseAuth.instance.currentUser!.uid);

    bool isAssigned = info?.isAssigned ?? false;
    bool isCompleted =
        isAssigned && info!.assignedEndDate!.isBefore(DateTime.now());
    return (!isCurrentUserOwner && isCurrentUserAnOrganisation)
        ? SizedBox.shrink()
        : (!isUserRegistered)
            ? Container(
                alignment: Alignment.center,
                height: 60,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8643FF), Color(0xFF4136F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      TextButton(
                          onPressed: () async {
                            registerUser();
                          },
                          child: Container(
                            height: 40,
                            width: 400,
                            alignment: Alignment.center,
                            child: _registrationInProgress
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text("Sign up",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.white,
                                    )),
                          ))
                    ])))
            : Container(
                alignment: Alignment.center,
                height: 60,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isCompleted
                        ? [Colors.green.shade400, Colors.greenAccent]
                        : isAssigned
                            ? [Colors.grey.shade400, Colors.blueGrey.shade500]
                            : [Colors.red.shade400, Colors.red.shade500],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      TextButton(
                          onPressed: () async {
                            if (isCompleted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => ReviewAndRating(
                                          eventId: widget
                                              .volunteeringEvent.reference!.id,
                                          eventName:
                                              widget.volunteeringEvent.name,
                                        )),
                              );
                              return;
                            }
                            if (isAssigned) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Cannot drop out as you are already assigned to a role'),
                              ));
                              return;
                            }
                            deregisterUser();
                          },
                          child: Container(
                            height: 40,
                            width: 400,
                            alignment: Alignment.center,
                            child: _registrationInProgress
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : Text(isCompleted ? 'Review' : "Drop out",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.white,
                                    )),
                          ))
                    ])));
  }

  Future<void> registerUser() async {
    setState(() {
      _registrationInProgress = true;
    });
    try {
      VolunteeringEventRegistration volunteeringEventRegistration =
          VolunteeringEventRegistration(
              userId: FirebaseAuth.instance.currentUser!.uid,
              eventId: widget.volunteeringEvent.reference!.id,
              isAssigned: false);
      VolunteeringEventRegistrationsDAO.addVolunteeringEventRegistration(
          volunteeringEventRegistration,
          _organiserDetails.UID,
          widget.volunteeringEvent);
      setState(() {
        isUserRegistered = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registered to event successfully'),
      ));
    } catch (e) {
      //print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error while registering'),
      ));
    }
    setState(() {
      _registrationInProgress = false;
    });
  }

  Future<void> deregisterUser() async {
    setState(() {
      _registrationInProgress = true;
    });
    try {
      VolunteeringEventRegistrationsDAO.removeVolunteeringEventRegistration(
          FirebaseAuth.instance.currentUser!.uid,
          widget.volunteeringEvent.reference!.id,
          widget.volunteeringEvent.name,
          _organiserDetails.UID);
      setState(() {
        isUserRegistered = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Dropped out of event successfully'),
      ));
    } catch (e) {
      //print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error while dropping out'),
      ));
    }
    setState(() {
      _registrationInProgress = false;
    });
  }

  buildOrganiserButton() {
    return Container(
        alignment: Alignment.center,
        height: 60,
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8643FF), Color(0xFF4136F1)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          Assignvolunteers(event: widget.volunteeringEvent),
                    ));
                  },
                  child: Container(
                    height: 40,
                    width: 400,
                    alignment: Alignment.center,
                    child: _registrationInProgress
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text("Manage",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white,
                            )),
                  ))
            ])));
  }

  Widget buildAssignedInformation(VolunteeringEventRegistration info) {
    DateTime? startDate = info.assignedStartDate;
    DateTime? endDate = info.assignedEndDate;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned Details:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            'Start Date: ${startDate != null ? formatDate(startDate) : 'Not Assigned'}',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(
            'End Date: ${endDate != null ? formatDate(endDate) : 'Not Assigned'}',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    // Format the date as needed (e.g., 'MM/dd/yyyy')
    return '${date.month}/${date.day}/${date.year}';
  }
}
// todo edit details if youre the orgniaser.
// todo max number spaces, join a waiting list?
