import 'package:HeartOfExperian/DataAccessLayer/VolunteeringEventFavouritesDAO.dart';
import 'package:HeartOfExperian/Pages/Attendees.dart';
import 'package:HeartOfExperian/Pages/ColleagueProfile.dart';
import 'package:HeartOfExperian/Pages/CustomWidgets/EventLocationMap.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../DataAccessLayer/UserDAO.dart';
import '../DataAccessLayer/VolunteeringEventRegistrationsDAO.dart';
import '../Models/UserDetails.dart';
import '../Models/VolunteeringEvent.dart';
import '../Models/VolunteeringEventFavourite.dart';
import '../Models/VolunteeringEventRegistration.dart';
import 'Chatroom.dart';
import 'CustomWidgets/BackButton.dart';

class VolunteeringEventDetailsPage extends StatefulWidget {
  final VolunteeringEvent volunteeringEvent;

  const VolunteeringEventDetailsPage({Key? key, required this.volunteeringEvent}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VolunteeringEventDetailsPageState();
}

class VolunteeringEventDetailsPageState extends State<VolunteeringEventDetailsPage> {
  bool areOrganiserDetailsLoading = true;
  late UserDetails _organiserDetails;
  late List<UserDetails> _attendees;
  int _selectedIndex = 0;
  bool _registrationInProgress = false;
  bool _addToCalendarInProgress = false;
  bool areAttendeeDetailsLoading = true;
  late bool isUserRegistered;
  late bool isFavourite;
  bool isFavouriteLoading = true;

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
      UserDetails? userDetails = await UserDAO.getUserDetails(widget.volunteeringEvent.organiserUID);
      setState(() {
        _organiserDetails = userDetails!;
        areOrganiserDetailsLoading = false;
      });
    } catch (e) {
      //print('Error fetching organiser user details: $e');
    }
  }

  Future<void> fetchAttendees() async {
    try {
      List<UserDetails> attendees = [];
      List<String> attendeeIds = await VolunteeringEventRegistrationsDAO.getAllUserIdsForEvent(widget.volunteeringEvent.reference.id);

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
        UserDetails? attendee = await UserDAO.getUserDetails(id);
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
          await VolunteeringEventFavouritesDAO.isEventFavouritedByUser(FirebaseAuth.instance.currentUser!.uid, widget.volunteeringEvent.reference.id);

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
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
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
                  buildAddToCalendarButton(context),
                  const SizedBox(width: 20),
                  !areAttendeeDetailsLoading ? buildRegisterButton(context) : const CircularProgressIndicator()
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
          fontSize: 27,
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
                    VolunteeringEventFavourite(userId: FirebaseAuth.instance.currentUser!.uid, eventId: widget.volunteeringEvent.reference.id);
                VolunteeringEventFavouritesDAO.addVolunteeringEventFavourite(volunteeringEventFavourite);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Added to favourites successfully'),
                ));
              } else {
                VolunteeringEventFavouritesDAO.removeVolunteeringEventFavourite(
                    FirebaseAuth.instance.currentUser!.uid, widget.volunteeringEvent.reference.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Removed from favourites successfully'),
                ));
              }
              setState(() {
                isFavouriteLoading = false;
              });
            },
            icon: isFavourite
                ? const FaIcon(FontAwesomeIcons.solidHeart, color: Colors.red, size: 30)
                : const FaIcon(FontAwesomeIcons.heart, color: Colors.red, size: 30), // todo click to favourite
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
          DateFormat('EEEE, d\'th\' MMMM yyyy').format(widget.volunteeringEvent.date),
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
              Text(
                _organiserDetails.forename + " " + _organiserDetails.surname,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          );
  }

  Widget buildAttendeesList() {
    // todo get it to overlap.
    Widget buildProfilePhoto(String photoUrl, {int index = 0}) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(photoUrl),
          ),
        ),
      );
    }

    return areAttendeeDetailsLoading // todo this doesnt overlap
        ? const CircularProgressIndicator()
        : Row(children: [
            for (int i = 0; i < _attendees.length && i < 4; i++) buildProfilePhoto(_attendees[i].profilePhotoUrl, index: i),
            if (_attendees.length > 4) ...[
              Text(
                '  +${_attendees.length - 4}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            TextButton(
              child: Column(children: [
                const Text('View all'),
                const Text('attendees'),
              ]),
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
          ]);
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
            border: Border.all(color: _selectedIndex == index ? Colors.blue : Colors.transparent),
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
        : const Text('The organiser has opted out of receiving event-related inquiries.');
  }

  Widget buildDescriptionDetails() {
    return Column(children: [
      Text(widget.volunteeringEvent.description.replaceAll("\\n", "\n")),
      const SizedBox(height: 15),
      widget.volunteeringEvent.website.isNotEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.globe, color: Colors.grey.shade500, size: 17),
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
                  Clipboard.setData(ClipboardData(text: widget.volunteeringEvent.location));
                },
              ),
            ]),
            EventLocationMap(eventLocation: new LatLng(widget.volunteeringEvent.latitude, widget.volunteeringEvent.longitude)),
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
                        builder: (context) => ColleagueProfilePage(UID: _organiserDetails.UID),
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
                        _organiserDetails.forename + " " + _organiserDetails.surname,
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
            buildMessagesButton(context),
          ]);
  }

  Widget buildMessagesButton(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'joinGroupChat',
          child: Text('Group Chat'),
        ),
        PopupMenuItem<String>(
          value: 'messagePerson',
          child: Text('Message ' + _organiserDetails.forename),
        ),
      ],
      onSelected: (String value) {
        if (value == 'joinGroupChat') {
          joinGroupChat(context);
        } else if (value == 'messagePerson') {
          messagePerson(context);
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: 50,
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
        child: const Center(
          child: Icon(
            Icons.messenger_outline_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  } //todo when you create event it creates the group chat.

  void messagePerson(BuildContext context) async {
    try {
      final String organiserId = _organiserDetails.UID;
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      final chatQuerySnapshot = await FirebaseFirestore.instance.collection('chats').where('users', arrayContains: currentUserId).get();

      final filteredChats = chatQuerySnapshot.docs.where((chatDoc) {
        List<dynamic> users = chatDoc['users'];
        return users.contains(organiserId) && users.length == 2;
      }).toList();

      if (filteredChats.length != 0) {
        final chatDoc = filteredChats.first;

        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => ChatroomPage(chat: chatDoc),
        ),
        );
        return;
      } else {
        final String chatName = _organiserDetails.forename + " " + _organiserDetails.surname;

        final List<String> memberIds = [];
        memberIds.add(organiserId);
        memberIds.add(currentUserId);

        final chatRef = await FirebaseFirestore.instance
            .collection('chats')
            .add({'chatName': chatName, 'users': memberIds, 'lastMessageTime': DateTime.now(), 'lastMessage': ''});

        final usersCollectionRef = chatRef.collection('users');

        for (final userId in memberIds) {
          await usersCollectionRef.doc(userId).set({
            'user': userId,
            'read': false,
          });
        }

        final chatQuerySnapshot = await FirebaseFirestore.instance.collection('chats').where('users', arrayContains: currentUserId).get();

        final filteredChats = chatQuerySnapshot.docs.where((chatDoc) {
          List<dynamic> users = chatDoc['users'];
          return users.contains(organiserId) && users.length == 2;
        }).toList();

        if (filteredChats.length != 0) {
          final chatDoc = filteredChats.first;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatroomPage(chat: chatDoc),
            ),
          );
        }
      }
    } catch (e) {
      //print('Error while trying to add user to chat: ' + e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('There was an error while trying to add you to the chat.'),
      ));
    }
  }

  void joinGroupChat(BuildContext context) async {
    try {
      final String eventID = widget.volunteeringEvent.reference.id;
      final String userIdToAdd = FirebaseAuth.instance.currentUser!.uid;

      final chatQuerySnapshot = await FirebaseFirestore.instance.collection('chats').where('eventId', isEqualTo: eventID).get();

      if (chatQuerySnapshot.docs.isNotEmpty) {
        final chatDoc = chatQuerySnapshot.docs.first;

        final usersCollectionRef = chatDoc.reference.collection('users');

        final userDoc = await usersCollectionRef.doc(userIdToAdd).get();
        if (userDoc.exists) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatroomPage(chat: chatDoc),
            ),
          );
          return;
        }

        await usersCollectionRef.doc(userIdToAdd).set({
          'user': userIdToAdd,
          'read': false,
        });

        List<String> currentUsers = List<String>.from(chatDoc['users']);

        currentUsers.add(userIdToAdd);

        await chatDoc.reference.update({
          'users': currentUsers,
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatroomPage(chat: chatDoc),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('There was an error while trying to add you to the group chat.'),
        ));
      }
    } catch (e) {
      //print('Error while trying to add user to group chat: ' + e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('There was an error while trying to add you to the group chat.'),
      ));
    }
  }

  Widget buildJoinGroupChatButton(BuildContext context) {
    return Container(
        alignment: Alignment.bottomCenter,
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
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          TextButton(
              onPressed: () async {
                joinGroupChat(context);
              },
              child: Container(
                height: 40,
                width: 400,
                alignment: Alignment.center,
                child: _registrationInProgress
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text("Group chat",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        )),
              ))
        ])));
  }

  Widget buildRegisterButton(BuildContext context) {
    return (!isUserRegistered)
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
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                colors: [Colors.red.shade400, Colors.red.shade500],
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
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              TextButton(
                  onPressed: () async {
                    deregisterUser();
                  },
                  child: Container(
                    height: 40,
                    width: 400,
                    alignment: Alignment.center,
                    child: _registrationInProgress
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text("Drop out",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white,
                            )),
                  ))
            ])));
  }

  Widget buildAddToCalendarButton(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: 60,
        width: 60,
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
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          TextButton(
              onPressed: () {
                addToCalendar();
              },
              child: Container(
                height: 40,
                width: 400,
                alignment: Alignment.center,
                child: _addToCalendarInProgress
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const FaIcon(FontAwesomeIcons.calendarPlus, color: Colors.white, size: 25), // todo get better icon
              ))
        ])));
  }

  void addToCalendar() {
    setState(() {
      _addToCalendarInProgress = true;
    });

    final Event event = Event(
      title: widget.volunteeringEvent.name,
      description: widget.volunteeringEvent.description,
      location: widget.volunteeringEvent.location,
      allDay: true,
      startDate: widget.volunteeringEvent.date,
      endDate: widget.volunteeringEvent.date.add(const Duration(days: 1)),
      androidParams: const AndroidParams(
        emailInvites: [], // on Android, you can add invite emails to your event.
      ),
    );

    Add2Calendar.addEvent2Cal(event);

    setState(() {
      _addToCalendarInProgress = false;
    });
  }

  Future<void> registerUser() async {
    setState(() {
      _registrationInProgress = true;
    });
    try {
      VolunteeringEventRegistration volunteeringEventRegistration = VolunteeringEventRegistration(
        userId: FirebaseAuth.instance.currentUser!.uid,
        eventId: widget.volunteeringEvent.reference.id,
      );
      VolunteeringEventRegistrationsDAO.addVolunteeringEventRegistration(volunteeringEventRegistration);
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
          FirebaseAuth.instance.currentUser!.uid, widget.volunteeringEvent.reference.id);
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
}
// todo edit details if youre the orgniaser.
// todo max number spaces, join a waiting list?
