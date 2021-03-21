import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'package:geodesy/geodesy.dart' as geo;

import 'package:park_buddy/control/MarkerIconGenerator.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';
import 'package:park_buddy/control/CarparkCSV.dart';

class MapView extends StatefulWidget {
  MapView({Key key}) : super(key: key);
  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _singapore = CameraPosition(
      bearing: 0, target: LatLng(1.3521, 103.8198), tilt: 0, zoom: 12);

  final Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    var location = await Location().getLocation();
    var filteredList = CarParkCSV.dataFilteredByDistance(CarParkCSV.carparkList,
        0.5, geo.LatLng(location.latitude, location.longitude));

    _refreshMarkers(filteredList);
  }

  void _refreshMarkers(List<CarparkInfo> list) {
    setState(() {
      _markers.clear();
      _fillDataToMarkers(_markers, list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('ParkBuddy Home'),
        backgroundColor: const Color(0x11000000),
        elevation: 0,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _singapore,
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
          if (await Permission.location.isGranted) {
            await _onMapCreated(controller);
          } else {
            await Permission.location.request();
            var isShown = await Permission.contacts.shouldShowRequestRationale;
            await _onMapCreated(controller);
          }
        },
        markers: _markers.values.toSet(),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
      extendBodyBehindAppBar: true,

      //TODO: parking lot list
      //         //TODO: connect each entry to carpark info page (same widget as map view)
      //           // TODO: onpress/ontap: Navigator.pushNamed(context, '/carparkinfopage', arguments ['HB12']);

      floatingActionButton: FloatingActionButton(
        onPressed: _zoomToCurrentLocation,
        child: Icon(Icons.location_on),
        elevation: 2,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Map<String, Marker> _fillDataToMarkers(
      Map<String, Marker> markers, List<CarparkInfo> data) {
    for (var i = 0; i < data.length; i++) {
      final carpark = data[i];
      final marker = Marker(
        markerId: MarkerId(carpark.carparkCode),
        position: LatLng(carpark.latlng.latitude, carpark.latlng.longitude),
        infoWindow: InfoWindow(
          title: carpark.carparkCode,
          snippet:
              '${carpark.address}, ${carpark.carparkPaymentMethod}, ${carpark.carparkType}, ${carpark.shortTermParking}',
          //TODO: UI for lot availability
          //TODO: backend for querying carpark API (able to query any
          onTap: () => _OpenDynamicInfoPage(carpark.carparkCode),
        ),
      );
      markers[carpark.carparkCode] = marker;
    }

    return markers;
  }

  void _OpenDynamicInfoPage(String carparkCode) {
    Navigator.pushNamed(context, '/carparkinfopage', arguments: carparkCode);
  }

  void _zoomToCurrentLocation() async {
    final controller = await _controller.future;
    LocationData currentLocation;
    var location = Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    _refreshMarkers(CarParkCSV.dataFilteredByDistance(CarParkCSV.carparkList,
        0.5, geo.LatLng(currentLocation.latitude, currentLocation.longitude)));

    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: await controller.getZoomLevel(),
      ),
    ));
  }

  void zoomToLocation(geo.LatLng location) async {
    final controller = await _controller.future;

    _refreshMarkers(CarParkCSV.dataFilteredByDistance(CarParkCSV.carparkList,
        0.5, geo.LatLng(location.latitude, location.longitude)));

    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(location.latitude, location.longitude),
        zoom:
            15, //15 displays all carparks in 500m radius. //TODO: to change this default value if we add radius slider
      ),
    ));
  }

  void addMarkerForLocation(String locationDetails, geo.LatLng location) async {
    final controller = await _controller.future;
    MarkerGenerator markerGen = MarkerGenerator(120);
    final marker = Marker(
        icon: await markerGen.createBitmapDescriptorFromIconData(
            Icons.location_history, Colors.blue, Colors.black, Colors.white),
        markerId: MarkerId(locationDetails),
        position: LatLng(location.latitude, location.longitude),
        onTap: () async {
          print(await controller.getZoomLevel());
        });
    setState(() {
      _markers["new"] = marker;
    });
  }
}
