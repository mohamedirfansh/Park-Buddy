import 'package:location/location.dart';


///The class responsible for all location queries.
/// {@category Control}
class LocationManager {
  ///Used when user is searching for a destination other than their own.
  static LocationData _intendedLocation;
  ///Used when user is searching for carparks around their current location.
  static LocationData _currentLocation;
  ///When true, the user is searching for carparks around their location. When false, the user is searching for a location in the search bar.
  static bool locationModeSelf = true;

  ///Used for simple caching timer so that we are not checking the user's location constantly.
  static DateTime _lastRefreshedTime = DateTime.now().subtract(Duration(seconds: 60));

  ///Internal method to get current location that handles and resets the caching timer.
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

  ///Externally facing property that returns a cached value if the location was recently updated.
  static Future<LocationData> get currentLocation async {
    if (DateTime.now().difference(_lastRefreshedTime).inSeconds > 10) {
      return await _getCurrentLocation();
    } else {
      return _currentLocation;
    }
  }

  ///Setter method for the internal _intendedLocation, for use when the user is using the search bar.
  ///We set the flag to false so that distance and carpark calculations are done correctly and not from the user's location.
  static set intendedLocation(LocationData location) {
    _intendedLocation = location;
    locationModeSelf = false;
  }

  ///Simple getter method for the internal value
  static LocationData get intendedLocation => _intendedLocation;

}