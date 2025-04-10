import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Pages/homepage.dart';
import 'firebase_options.dart'; // Import Firebase Options
import 'package:permission_handler/permission_handler.dart';

import 'Pages/Authentication/SignIn.dart';
import 'Pages/NavBarManager.dart';
import 'Pages/SearchVolunteering.dart';
import 'Pages/Settings/SharedPreferences.dart';
import 'notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Use FirebaseOptions for initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService.initilizeNotification();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> mainNavigationKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> loginNavigationKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Volunteer Impact',
      debugShowCheckedModeBanner: false,
      navigatorKey: mainNavigationKey,
      home: FutureBuilder<bool>(
        future: SignInSharedPreferences.isSignedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // ✅ Wrapped in Center
          }
          final bool isAuthenticated = snapshot.data ?? false;
          if (isAuthenticated) {
            return MainApplication(
                loginNavigationKey: loginNavigationKey,
                mainNavigationKey: mainNavigationKey);
          } else {
            return LoginPage(
                loginNavigationKey: loginNavigationKey,
                mainNavigationKey: mainNavigationKey);
          }
        },
      ),
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4136F1),
        ).copyWith(background: Colors.white),
      ),
    );
  }
}

class MainApplication extends StatelessWidget {
  final GlobalKey<NavigatorState> mainNavigationKey;
  final GlobalKey<NavigatorState> loginNavigationKey;

  const MainApplication(
      {Key? key,
      required this.mainNavigationKey,
      required this.loginNavigationKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: loginNavigationKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => NavBarManager(
            initialIndex: 0,
            searchVolunteeringPage: SearchVolunteeringPage(),
            feedPage: Homepage(
              mainNavigatorKey: mainNavigationKey,
              logInNavigatorKey: loginNavigationKey,
            ),
            mainNavigatorKey: mainNavigationKey,
            logInNavigatorKey: loginNavigationKey,
          ),
        );
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  final GlobalKey<NavigatorState> loginNavigationKey;
  final GlobalKey<NavigatorState> mainNavigationKey;

  const LoginPage(
      {Key? key,
      required this.loginNavigationKey,
      required this.mainNavigationKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: loginNavigationKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => SignInPage(
            logInNavigatorKey: loginNavigationKey,
            mainNavigatorKey: mainNavigationKey,
          ),
        );
      },
    );
  }
}
