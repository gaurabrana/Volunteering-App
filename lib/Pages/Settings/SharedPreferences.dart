import 'dart:convert';

import 'package:VolunteeringApp/Models/UserDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInSharedPreferences {
  Future<bool> isSignedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSignedIn') ?? false;
  }

  Future<void> setSignedIn(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', value);
  }

  /// Save user details to SharedPreferences
  Future<void> setCurrentUserDetails(UserDetails details) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(details.toJson());
    await prefs.setString('userDetails', jsonString);
  }

  /// Get user details from SharedPreferences
  Future<UserDetails?> getCurrentUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('userDetails');

    if (jsonString != null) {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return UserDetails.fromJson(map);
    }

    return null;
  }

  /// Clear stored user details on logout
  Future<void> clearCurrentUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userDetails');
  }
}
