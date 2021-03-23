import 'package:geolocator/geolocator.dart';

class LocationManager {
  static Position _currentLocation;
  void _locateUser() async {
    _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Position get currentLocation {
    _locateUser();
    return _currentLocation;
  }
}