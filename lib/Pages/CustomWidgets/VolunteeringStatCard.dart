import 'package:HeartOfExperian/Pages/Leaderboard.dart';
import 'package:HeartOfExperian/Pages/NavBarManager.dart';
import 'package:HeartOfExperian/Pages/Team.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../ColleagueProfile.dart';
import '../Feed.dart';
import '../Profile.dart';
import '../RecordVolunteering.dart';
import '../SearchVolunteering.dart';

class UserVolunteeringStatCard extends StatefulWidget {
  final String id;
  final String name;
  final String profilePhotoURL;
  final int hours;
  final int rank;
  final bool isCurrentUser;
  final bool isTeamStat;

  const UserVolunteeringStatCard({
    Key? key,
    required this.id,
    required this.name,
    required this.hours,
    required this.profilePhotoURL,
    required this.rank,
    required this.isCurrentUser,
    required this.isTeamStat,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => VolunteeringStatCardState();
}

class VolunteeringStatCardState extends State<UserVolunteeringStatCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              gradient: widget.isCurrentUser
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF8643FF), Color(0xFF4136F1)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.white],
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 10,
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30.0), // Set the same border radius as the Card
                  onTap: () {
                    if (!widget.isTeamStat) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ColleagueProfilePage(
                            UID: widget.id
                        ),
                      ));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TeamPage(teamId: widget.id),
                      ));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 5),
                    child: ListTile(
                      leading: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              widget.profilePhotoURL,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (widget.rank == 1)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Transform.translate(
                                    offset: const Offset(1, -12),
                                    child: FaIcon(
                                      FontAwesomeIcons.crown,
                                      color: Colors.yellow.shade600,
                                      size: 20,
                                    )),
                              ),
                            ),
                          if (widget.rank == 2)
                            Positioned(
                                top: 0,
                                left: 0,
                                child: Transform.rotate(
                                    angle: -0.5,
                                    child: Transform.translate(
                                      offset: const Offset(1, -12),
                                      child: FaIcon(
                                        FontAwesomeIcons.crown,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ))),
                          if (widget.rank == 3)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Transform.rotate(
                                  angle: -0.5,
                                  child: Transform.translate(
                                    offset: const Offset(1, -12),
                                    child: FaIcon(
                                      FontAwesomeIcons.crown,
                                      color: Color(0xFFCD7F32),
                                      size: 20,
                                    ),
                                  )),
                            )
                        ],
                      ),
                      title: Text(
                        widget.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.isCurrentUser ? Colors.white : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      subtitle: Text(
                        '${widget.hours} hours',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: widget.isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Text(
                        widget.rank.toString() + _getRankSuffix(widget.rank),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: widget.isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ))));
  }

  String _getRankSuffix(int rank) {
    if (rank >= 11 && rank <= 13) {
      return 'th';
    } else {
      switch (rank % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }
  }
}
//todo when the names span 2 lines the profile photos arent aligned
