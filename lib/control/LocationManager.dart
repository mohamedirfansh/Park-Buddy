import 'package:location/location.dart';

class LocationManager {
  static LocationData _currentLocation;
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
}