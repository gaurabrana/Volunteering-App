import 'package:VolunteeringApp/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

import '../fcm_manager.dart';
import '../notification.dart';
import 'Profile.dart';
import 'SearchVolunteering.dart';
import 'homepage.dart';

class NavBarManager extends StatefulWidget {
  final int initialIndex;
  final SearchVolunteeringPage searchVolunteeringPage;
  final Homepage feedPage;

  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> logInNavigatorKey;

  const NavBarManager({
    Key? key,
    required this.initialIndex,
    required this.searchVolunteeringPage,
    required this.feedPage,
    required this.mainNavigatorKey,
    required this.logInNavigatorKey,
  }) : super(key: key);

  @override
  _NavBarManagerState createState() => _NavBarManagerState();
}

class _NavBarManagerState extends State<NavBarManager>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late List<Widget> _bodies = [];

  int currentActiveIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService().requestPermissions();
    NotificationService().isAndroidPermissionGranted();
    FirebaseMessagingManager.initializeFirebaseMessaging();
    currentActiveIndex = widget.initialIndex;
    getBodies();
  }

  @override
  void dispose() {
    // Unregister the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle state changes
    if (state == AppLifecycleState.detached) {
      FCMService.closeClient();
    }
  }

  void getBodies() {
    _bodies = [
      widget.feedPage,
      widget.searchVolunteeringPage,
      ProfilePage(
        mainNavigatorKey: widget.mainNavigatorKey,
        loginNavigatorKey: widget.logInNavigatorKey,
      )
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      currentActiveIndex = index;
    });
    //widget.mainNavigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => _bodies[currentActiveIndex]));
  }

  List<SMIInput<bool>?> inputs = [];
  List<Artboard> artboards = [];

  List<String> assetPaths = [
    "assets/animations/home_animation.riv",
    "assets/animations/search_animation.riv",
    "assets/animations/profile_animation.riv",
  ];

  initializeArtboard() async {
    for (var path in assetPaths) {
      final data = await rootBundle.load(path);
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      final controller =
          StateMachineController.fromArtboard(artboard, "State Machine 1");
      SMIInput<bool>? input;
      if (controller != null) {
        artboard.addController(controller);
        input = controller.findInput<bool>("status");
        input!.value = true;
      }
      inputs.add(input);
      artboards.add(artboard);
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await initializeArtboard();
    setState(() {});
  }

  List<double?> iconSizes = [38, 45, 45, 45];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        // body: Builder(
        //   builder: (context) {
        //     return Navigator(
        //       key: widget.mainNavigatorKey,
        //       onGenerateRoute: (settings) {
        //         return MaterialPageRoute(
        //           builder: (_) => _bodies[currentActiveIndex],
        //         );
        //       },
        //     );
        //   },
        // ),
        // body: _bodies[currentActiveIndex],
        body: _bodies[currentActiveIndex],
        bottomNavigationBar: getBottomNavBar());
  }

  Widget getBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 10,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          artboards.length,
          (index) {
            return Flexible(
              child: BottomAppBarItem(
                artboard: artboards[index],
                currentIndex: currentActiveIndex,
                tabIndex: index,
                input: inputs[index],
                onpress: () {
                  _onItemTapped(index);
                },
                iconSize: iconSizes[index],
                label: index == 0
                    ? 'Home'
                    : index == 1
                        ? 'Events'
                        : index == 2
                            ? 'Profile'
                            : '',
              ),
            );
          },
        ),
      ),
    );
  }
}

class BottomAppBarItem extends StatelessWidget {
  const BottomAppBarItem({
    Key? key,
    required this.artboard,
    required this.onpress,
    required this.currentIndex,
    required this.tabIndex,
    required this.input,
    required this.iconSize,
    required this.label,
  }) : super(key: key);

  final Artboard? artboard;
  final VoidCallback onpress;
  final int currentIndex;
  final int tabIndex;
  final SMIInput<bool>? input;
  final double? iconSize;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (input != null) {
      input!.value = currentIndex == tabIndex;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: GestureDetector(
            onTap: onpress,
            child:
                artboard == null ? const SizedBox() : Rive(artboard: artboard!),
          ),
        ),
        if (label != "")
          Text(
            label,
            style: TextStyle(
              fontWeight: currentIndex == tabIndex
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: currentIndex == tabIndex
                  ? Color(0xFF8643FF)
                  : Color(0xFF8643FF).withOpacity(0.2),
            ),
          ),
      ],
    );
  }
}
