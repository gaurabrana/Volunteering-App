import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package

class LocationInputInputField extends StatefulWidget {
  final TextEditingController locationController;
  late String? locationAddress;
  late double? latitude;
  late double? longitude;
  late bool locationFound;

  LocationInputInputField({
    super.key,
    required this.locationController,
  });

  @override
  _LocationInputInputFieldState createState() => _LocationInputInputFieldState();

  Future<void> getLocationCoordinates() async {
    try {
      List<Location> locations = await locationFromAddress(locationController.text);
      if (locations.isNotEmpty) {
        latitude = locations.first.latitude;
        longitude = locations.first.longitude;
        locationAddress = locationController.text;
        locationFound = true;
      } else {
        locationAddress = 'Location not found';
        latitude = null;
        longitude = null;
        locationFound = false;
      }
    } catch (e) {
      locationFound = false;
      print('Error retrieving location: $e');
    }
  }
}

class _LocationInputInputFieldState extends State<LocationInputInputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.locationController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: 'Enter postcode or location name',
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
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
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please enter the location of the event';
        }
        return null;
      },
    );
  }
}
