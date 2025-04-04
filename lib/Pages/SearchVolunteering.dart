import 'package:HeartOfExperian/Models/VolunteeringEvent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../DataAccessLayer/VolunteeringEventDAO.dart';
import '../DataAccessLayer/VolunteeringEventFavouritesDAO.dart';
import '../DataAccessLayer/VolunteeringHistoryDAO.dart';
import 'CreateVolunteeringEvent.dart';
import 'CustomWidgets/VolunteeringEventCard.dart';

class SearchVolunteeringPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchVolunteeringPageState();
}

class SearchVolunteeringPageState extends State<SearchVolunteeringPage> {
  late List<VolunteeringEvent> _volunteeringEvents;
  late List<VolunteeringEvent> _filteredEvents;
  bool _areEventsLoading = true;
  late Widget eventsList;
  TextEditingController _searchController = TextEditingController();
  List<String> volunteeringTypes = VolunteeringHistoryDAO.volunteeringTypesWithAny;
  List<String> deliveryTypes = ['Any', 'Online', 'In person'];
  int volunteeringTypesIndex = 0;
  int deliveryTypeIndex = 0;

  // Filters
  String _selectedType = 'Any';
  String _selectedLocation = '';
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(Duration(days: 2191));
  String _selectedDeliveryFormat = 'Any';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void initialiseData() {
    setState(() {
      _volunteeringEvents = [];
      _filteredEvents = [];
      _areEventsLoading = true;
    });
  }

  Future<void> fetchData() async {
    initialiseData();
    try {
      List<VolunteeringEvent>? volunteeringEvents = await VolunteeringEventDAO.getAllFutureVolunteeringEvents();
      setState(() {
        if (volunteeringEvents != null) {
          _volunteeringEvents = volunteeringEvents;
          _filteredEvents = volunteeringEvents;
        }
      });

      var eventList = await buildEventsList(context);
      setState(() {
        eventsList = eventList;
        _areEventsLoading = false;
      });
    } catch (error) {
      //print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: RefreshIndicator(
        onRefresh: fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                buildTitleAndAddButton(),
                buildSearchBar(),
                const SizedBox(height: 16),
                _areEventsLoading
                    ? const CircularProgressIndicator()
                    : FutureBuilder<Widget>(
                        future: buildEventsList(context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return snapshot.data ?? Container();
                          }
                        },
                      ),
              ],
            ),
          ),
        )));
  }

  Widget buildTitleAndAddButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const SizedBox(width: 40),
      const Text(
        'Find events',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          decorationColor: Colors.black,
        ),
      ),
      buildAddEventButton(context),
    ]);
  }

  Widget buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0.5,
                  blurRadius: 10,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                filterEvents(value);
              },
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade500, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Colors.red.shade700,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            // Show filter options
            showFilterOptions(context);
          },
        ),
      ],
    );
  }

  void showFilterOptions(BuildContext context) {
    List<Widget> volunteeringTypeButtons = [];
    List<Widget> deliveryTypeButtons = [];

    for (int i = 0; i < volunteeringTypes.length; i++) {
      volunteeringTypeButtons.add(TextButton(
        onPressed: () {
          setState(() {
            volunteeringTypesIndex = i; // todo allow to select > 1
            _selectedType = volunteeringTypes[volunteeringTypesIndex];
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            return Colors.white;
          }),
          textStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
            return volunteeringTypesIndex == i
                ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.grey.shade600); // Set the text color and style based on selection
          }),
          side: MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> states) {
            return volunteeringTypesIndex == i
                ? const BorderSide(color: Colors.purple, width: 2.0)
                : const BorderSide(color: Colors.grey, width: 1.0); // Set the border color and width based on selection
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Set the border radius
            ),
          ),
        ),
        child: Text(
          volunteeringTypes[i],
          style: volunteeringTypesIndex == i
              ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
              : TextStyle(color: Colors.grey.shade600, fontFamily: 'Poppins'),
        ),
      ));
    }
    ;

    for (int i = 0; i < deliveryTypes.length; i++) {
      deliveryTypeButtons.add(TextButton(
        onPressed: () {
          setState(() {
            deliveryTypeIndex = i; // todo allow to select > 1
            _selectedDeliveryFormat = deliveryTypes[i];
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            return Colors.white;
          }),
          textStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
            return deliveryTypeIndex == i
                ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.grey.shade600); // Set the text color and style based on selection
          }),
          side: MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> states) {
            return deliveryTypeIndex == i
                ? const BorderSide(color: Colors.purple, width: 2.0)
                : const BorderSide(color: Colors.grey, width: 1.0); // Set the border color and width based on selection
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Set the border radius
            ),
          ),
        ),
        child: Text(
          deliveryTypes[i],
          style: deliveryTypeIndex == i
              ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
              : TextStyle(color: Colors.grey.shade600, fontFamily: 'Poppins'),
        ),
      ));
    }
    ;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(
              'Filter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 25,
                decorationColor: Colors.black,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Types',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      decorationColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10.0, // spacing between buttons
                    runSpacing: 2.0, // spacing between rows
                    children: volunteeringTypeButtons,
                  ),
                  SizedBox(height: 10),
                  const Text(
                    'Delivery type',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      decorationColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10.0, // spacing between buttons
                    runSpacing: 2.0, // spacing between rows
                    children: deliveryTypeButtons,
                  ),
                  SizedBox(height: 16),
                  const Text(
                    'Location',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      decorationColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: 'Location',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text(
                    'Date',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      decorationColor: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: buildStartDatePicker(context),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: buildEndDatePicker(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Container(
                  alignment: Alignment.center,
                  height: 60,
                  width: 500,
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
                          filterEvents(_searchController.text);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 40,
                          width: 310,
                          alignment: Alignment.center,
                          child: const Text("Apply",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.white,
                              )),
                        )),
                  ])))
            ]);
      },
    );
  }

  Widget buildStartDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectStartDate(context);
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${DateFormat('dd/MM/yy').format(_selectedStartDate!)}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEndDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectEndDate(context);
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${DateFormat('dd/MM/yy').format(_selectedEndDate!)}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 2191)),
    );
    setState(() {
      if (picked != null) _selectedStartDate = picked;
    });
    //if (picked != null) print({picked.toString()});
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 2191)),
    );
    setState(() {
      if (picked != null) _selectedEndDate = picked;
    });
    //if (picked != null) print({picked.toString()});
  }

  Future<Widget> buildEventsList(BuildContext context) async {
    Future<bool> fetchIsFavourite(VolunteeringEvent event) async {
      try {
        bool favourite = await VolunteeringEventFavouritesDAO.isEventFavouritedByUser(FirebaseAuth.instance.currentUser!.uid, event.reference.id);
        return favourite;
      } catch (e) {
        //print('Error fetching favourite: $e');
        return false;
      }
    }

    List<Widget> eventCards = [];
    for (int i = 0; i < _filteredEvents.length; i++) {
      VolunteeringEvent eventData = _filteredEvents[i];
      bool isFavourite = await fetchIsFavourite(eventData);
      eventCards.add(
        VolunteeringEventCard(
          event: eventData,
          name: eventData.name,
          location: eventData.location,
          date: eventData.date,
          photoURL: eventData.photoUrls[0],
          isFavourite: isFavourite,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: eventCards,
    );
  }

  void filterEvents(String query) {
    List<VolunteeringEvent> filteredList = _volunteeringEvents.where((event) {
      bool matchesQuery = event.name.toLowerCase().contains(query.toLowerCase());

      bool matchesDeliveryType = _selectedDeliveryFormat == 'Any' ||
          (event.online && _selectedDeliveryFormat == 'Online') ||
          (!event.online && _selectedDeliveryFormat == 'In person');

      bool matchesType = _selectedType == 'Any' || event.type == _selectedType;

      bool matchesLocation = _selectedLocation.isEmpty || event.location.toLowerCase().contains(_selectedLocation.toLowerCase());

      bool matchesDateRange = _selectedStartDate == null ||
          _selectedEndDate == null ||
          (event.date.isAfter(_selectedStartDate!) && event.date.isBefore(_selectedEndDate!));

      return matchesQuery && matchesType && matchesLocation && matchesDateRange && matchesDeliveryType;
    }).toList();

    setState(() {
      _filteredEvents = filteredList;
    });
  }

  Widget buildAddEventButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
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
        child: Center(
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CreateVolunteeringEventPage()),
              );
            },
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
            color: const Color(0xFF4136F1),
          ),
        ),
      ),
    );
  }
}
