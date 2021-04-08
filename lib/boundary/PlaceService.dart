import 'dart:convert';

import 'package:geodesy/geodesy.dart';
import 'package:http/http.dart';

///The suggestion class. The placeID is used later when the user clicks on a suggestion for us to query for the suggestion's location information
///@see getPlaceLatLngFromId
class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion($placeId, $description)';
  }
}

///This class provides access to the Google Places API. This API is responsible for the autocomplete suggestions when the user is searching for location with the search bar.
class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;
  final apiKey = 'AIzaSyAZgPwhId1JCrLpMzgCfPABeGYV8Fkso-U';

  ///Fetches suggestions using the Google Places API. This search is done in the device's local language.
  ///@param input The string input from the search bar
  ///@param lang The language code that the phone uses.
  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=$lang&components=country:sg&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        print("no results");
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  ///Async operation to use the placeID to get the LatLng data from the Google Places API.
  ///@param placeId the placeID that was attached to the suggestion in the search bar dropdown.
  Future<LatLng> getPlaceLatLngFromId(String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry/location&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return LatLng(result['result']['geometry']['location']['lat'],
            result['result']['geometry']['location']['lng']);
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
