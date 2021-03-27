import 'package:location/location.dart';

class LocationManager {
  static LocationData _intendedLocation;
  static LocationData _currentLocation;
  static bool locationModeSelf = true; // True: destination is self. False: destination searched on search bar.
  static DateTime _lastRefreshedTime = DateTime.now().subtract(Duration(seconds: 60));

  static Future<LocationData> _getCurrentLocation() async {
    LocationData data;
    var location = Location();
    try {
      data = await location.getLocation();
      _lastRefreshedTime = DateTime.now();
      _currentLocation = data;
      return data;
    } on Exception {
      return currentLocation;
    }
  }

  static Future<LocationData> get currentLocation async {
    if (DateTime.now().difference(_lastRefreshedTime).inSeconds > 10) {
      return await _getCurrentLocation();
    } else {
      return _currentLocation;
    }
  }

  static set intendedLocation(LocationData location) {
    _intendedLocation = location;
    locationModeSelf = false;
  }

  static LocationData get intendedLocation => _intendedLocation;

}