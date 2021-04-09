import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:park_buddy/control/LocationManager.dart';

import 'package:park_buddy/entity/CarparkPaymentMethod.dart';
import 'package:park_buddy/entity/CarparkType.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';
import 'package:park_buddy/control/MarkerIconGenerator.dart';
import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/control/ScreenManager.dart';

///This class displays the map view, including the carpark markers that represent carparks near the user.
/// {@category Boundary}
class MapView extends StatefulWidget {
  MapView({Key key}) : super(key: key);
  @override
  MapViewState createState() => MapViewState();
}


///The state class for the map view.
class MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();

  /// Camera position to show at initial app startup.
  static final CameraPosition _singapore = CameraPosition(
      bearing: 0, target: LatLng(1.3521, 103.8198), tilt: 0, zoom: 12);

  ///A map of String to markers. Each marker is a carpark.
  final Map<String, Marker> _markers = {};

  ///On creation of the map, we wait for the user's location and filter carparks within 500m of the user and refresh the map markers.
  ///We also centre the map camera on the user's location.
  Future<void> _onMapCreated() async {
    var location = await LocationManager.currentLocation;
    var filteredList = CarparkInfoManager.filterCarparksByDistance(
        0.5,
        geo.LatLng(location.latitude, location.longitude));

    _refreshMarkers(filteredList);
    _zoomToCurrentLocation();
  }

  ///Uses setState to rebuild the map with a new [list] of carparks.
  ///If the [list] is empty, show a SnackBar indicating to the user that there are no nearby carparks.
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


  ///Builds the widget with an appbar, the GoogleMap (provided by Google Map API) and checks for user location permissions.
  ///Asks for user location if not granted.
  ///Takes the _markers list to populate carparks in area.
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
            await _onMapCreated();
          } else {
            await Permission.location.request();
            await _onMapCreated();
          }
        },
        markers: _markers.values.toSet(),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _zoomToCurrentLocation,
        child: Icon(Icons.location_on),
        elevation: 2,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  ///Fills the list of [markers] containing with the appropriate [data] like type of payment, type of carpark (surface, multistorey etc).
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
          ///Connect each marker to open a dynamic info page using ScreenManager.
          onTap: () => ScreenManager.openDynamicInfoPage(context, carpark.carparkCode, null),
        ),
      );
      markers[carpark.carparkCode] = marker;
    }

    return markers;
  }

  ///Moves the map camera to the user's current location and shows all the carparks within 500m of the user's location.
  void _zoomToCurrentLocation() async {

    var currentLocation = await LocationManager.currentLocation;
    LocationManager.locationModeSelf = true;

    zoomToLocation(geo.LatLng(currentLocation.latitude, currentLocation.longitude));
  }

  ///Moves the map camera to the given location. Additionally, it shows all the carparks within 500m of the given location.
  void zoomToLocation(geo.LatLng location) async {
    final controller = await _controller.future;

    _refreshMarkers(CarparkInfoManager.filterCarparksByDistance(
        0.5,
        geo.LatLng(location.latitude, location.longitude)));

    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(location.latitude, location.longitude),
        zoom: 15, //displays all car parks in 500m radius.
      ),
    ));
  }

  ///This adds a location marker that is different from the red carpark markers, indicating the location that the user searched.
  void addMarkerForLocation(String locationDetails, geo.LatLng location) async {
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

  ///Returns a formatted string to display for a carpark marker, given the CarparkInfo. The string contains the carpark type and payment type.
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
