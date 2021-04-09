import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:park_buddy/control/LocationManager.dart';

import 'package:park_buddy/entity/CarparkPaymentMethod.dart';
import 'package:park_buddy/entity/CarparkType.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';
import 'package:park_buddy/control/MarkerIconGenerator.dart';
import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/control/ScreenManager.dart';

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
    var location = await LocationManager.currentLocation;
    var filteredList = CarparkInfoManager.filterCarparksByDistance(
        CarparkInfoManager.carparkList,
        0.5,
        geo.LatLng(location.latitude, location.longitude));

    _refreshMarkers(filteredList);
    _zoomToCurrentLocation();
  }

  void _refreshMarkers(List<CarparkInfo> list) {
    setState(() {
      _markers.clear();
      _fillDataToMarkers(_markers, list);
      if (list.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No HDB carparks found in this area!', textAlign: TextAlign.center),
            duration: const Duration(milliseconds: 3000),
            width: 260.0, // Width of the SnackBar.
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0, // Inner padding for SnackBar content.
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        );
      }
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
          title: carpark.address,
          snippet: _formatCarparkInformationForMarker(carpark),
          //TODO: UI for lot availability
          //TODO: backend for querying carpark API (able to query anyR
          onTap: () => ScreenManager.openDynamicInfoPage(context, carpark.carparkCode, null),
        ),
      );
      markers[carpark.carparkCode] = marker;
    }

    return markers;
  }

  void _zoomToCurrentLocation() async {
    final controller = await _controller.future;

    var currentLocation = await LocationManager.currentLocation;
    LocationManager.locationModeSelf = true;
    _refreshMarkers(CarparkInfoManager.filterCarparksByDistance(
        CarparkInfoManager.carparkList,
        0.5,
        geo.LatLng(currentLocation.latitude, currentLocation.longitude)));

    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 15.0,
      ),
    ));
  }

  void zoomToLocation(geo.LatLng location) async {
    final controller = await _controller.future;

    _refreshMarkers(CarparkInfoManager.filterCarparksByDistance(
        CarparkInfoManager.carparkList,
        0.5,
        geo.LatLng(location.latitude, location.longitude)));

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
    );
    setState(() {
      _markers["new"] = marker;
    });
  }

  String _formatCarparkInformationForMarker(CarparkInfo carparkInfo) {
    String carparkType = ' Carpark';
    switch (carparkInfo.carparkType) {
      case CarparkType.multistoreyAndSurface:
        carparkType = 'Multistorey and Surface' + carparkType;
        break;
      case CarparkType.multistorey:
        carparkType = 'Multistorey' + carparkType;
        break;
      case CarparkType.mechanisedAndSurface:
        carparkType = 'Mechanised Surface' + carparkType;
        break;
      case CarparkType.mechanised:
        carparkType = 'Mechanised' + carparkType;
        break;
      case CarparkType.covered:
        carparkType = 'Covered' + carparkType;
        break;
      case CarparkType.surface:
        carparkType = 'Surface' + carparkType;
        break;
      case CarparkType.basement:
        carparkType = 'Basement' + carparkType;
        break;
    }

    String paymentType = '';

    switch (carparkInfo.carparkPaymentMethod) {
      case CarparkPaymentMethod.couponParking:
        paymentType = "Coupon Parking";
        break;
      case CarparkPaymentMethod.electronicParking:
        paymentType = "Electronic Parking";
        break;
    }

    return carparkType + ', ' + paymentType;
  }
}
