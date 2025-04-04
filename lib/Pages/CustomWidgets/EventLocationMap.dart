import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventLocationMap extends StatelessWidget {
  final LatLng eventLocation;

  const EventLocationMap({Key? key, required this.eventLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 200,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: eventLocation,
              zoom: 15,
            ),
            markers: Set.of([
              Marker(
                markerId: MarkerId('event_location'),
                position: eventLocation,
                infoWindow: InfoWindow(title: 'Event Location'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
