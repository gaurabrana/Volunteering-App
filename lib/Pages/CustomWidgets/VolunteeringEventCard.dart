import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../DataAccessLayer/VolunteeringEventFavouritesDAO.dart';
import '../../Models/VolunteeringEvent.dart';
import '../../Models/VolunteeringEventFavourite.dart';
import '../VolunteeringEventDetails.dart';

class VolunteeringEventCard extends StatefulWidget {
  final String name;
  final String location;
  final DateTime date;
  final String photoURL;
  bool isFavourite;
  final VolunteeringEvent event;

  VolunteeringEventCard({
    Key? key,
    required this.name,
    required this.location,
    required this.photoURL,
    required this.isFavourite,
    required this.event,
    required this.date,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => VolunteeringEventCardState();
}

class VolunteeringEventCardState extends State<VolunteeringEventCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => VolunteeringEventDetailsPage(volunteeringEvent: widget.event),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(10.0),
          margin: EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 10,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(
              left: -30,
              top: 5,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 10,
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.photoURL,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
                right: 10,
                top: -25,
                child: Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 10,
                          blurRadius: 15,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: buildFavouriteButton())),
            Row(
              children: [
                SizedBox(width: 75),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 190),
                        child: Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: Colors.grey.shade500, size: 15),
                          SizedBox(width: 5),
                          Container(
                            constraints: BoxConstraints(maxWidth: 190),
                            child: Text(
                              widget.location,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey.shade500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, color: Colors.grey.shade500, size: 15),
                          SizedBox(width: 5),
                          Text(
                            "${DateFormat('dd/MM/yy').format(widget.date)}",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget buildFavouriteButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          widget.isFavourite = !widget.isFavourite;
        });
        if (widget.isFavourite) {
          VolunteeringEventFavourite volunteeringEventFavourite =
              VolunteeringEventFavourite(userId: FirebaseAuth.instance.currentUser!.uid, eventId: widget.event.reference.id);
          VolunteeringEventFavouritesDAO.addVolunteeringEventFavourite(volunteeringEventFavourite);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Added to favourites successfully'),
          ));
        } else {
          VolunteeringEventFavouritesDAO.removeVolunteeringEventFavourite(FirebaseAuth.instance.currentUser!.uid, widget.event.reference.id);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Removed from favourites successfully'),
          ));
        }
      },
      icon: widget.isFavourite
          ? const FaIcon(FontAwesomeIcons.solidHeart, color: Colors.red, size: 25)
          : const FaIcon(FontAwesomeIcons.heart, color: Colors.red, size: 25),
    );
  }
}
