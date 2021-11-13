import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemap/domain/city.dart';
import 'package:googlemap/util/marker_generator.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  List<Marker> _markers = [];

  final LatLng _center = const LatLng(47.884640, 35.013440);

  final List<City> _cities = [
    City("Home", const LatLng(47.884640, 35.013440)),
  ];

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),
        markers: _markers.toSet(),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    MarkerGenerator(_getMarkerWidgets(), (List<Uint8List> bitmaps) {
      setState(() {
        _markers = _mapBitmapsToMarkers(bitmaps: bitmaps, cities: _cities);
      });
    }).afterFirstLayout(context);
  }

  List<Marker> _mapBitmapsToMarkers({
    required List<Uint8List> bitmaps,
    required List<City> cities,
  }) {
    final List<Marker> markersList = [];
    bitmaps.asMap().forEach((int i, Uint8List bmp) {
      markersList.add(
        Marker(
          markerId: const MarkerId('marker_id'),
          position: cities[i].position,
          infoWindow: const InfoWindow(
            title: "title info window",
            snippet: "snippet info window",
          ),
          icon: BitmapDescriptor.fromBytes(bmp),
          // hiding InfoWindow
          consumeTapEvents: true,
          onTap: () => debugPrint("Clicked "),
        ),
      );
    });
    return markersList;
  }

  List<Widget> _getMarkerWidgets() {
    return _cities.map((City city) => _getMarkerWidget(city.name)).toList();
  }

  Widget _getMarkerWidget(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kIsWeb ? 3 : 6),
        border: Border.all(),
        color: const Color.fromRGBO(255, 255, 255, 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.bug_report,
            size: kIsWeb ? 6 : 28,
            color: Colors.green,
          ),
          Text(
            name,
            style: kIsWeb
                ? Theme.of(context).textTheme.overline?.copyWith(fontSize: 6)
                : Theme.of(context).textTheme.headline5,
          ),
        ],
      ),
    );
  }
}
