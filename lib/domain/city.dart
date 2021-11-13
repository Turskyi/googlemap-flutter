import 'package:google_maps_flutter/google_maps_flutter.dart';

class City {
  City(this.name, this.position);

  final String name;
  final LatLng position;
}
