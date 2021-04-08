import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:location/location.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:uuid/uuid.dart';

import 'package:park_buddy/boundary/MapView.dart';
import 'package:park_buddy/boundary/PlaceService.dart';

import 'LocationManager.dart';

///The control class that handles the location searching. Comprises of the mapview as well as the autocompleting search bar.
class MapViewWithSearch extends StatefulWidget {
  @override
  _MapViewWithSearchState createState() => _MapViewWithSearchState();
}

///The state class for the Widget.
class _MapViewWithSearchState extends State<MapViewWithSearch> {
  final _controller = TextEditingController();
  final _searchBarController = FloatingSearchBarController();
  ///Generate a UUID for the autocomplete session. This tags the autocomplete query with an ID to prevent our cloud service from being overcharged for multiple services.
  _MapViewWithSearchState() {
    this.sessionToken = Uuid().v4();
    apiClient = PlaceApiProvider(sessionToken);
  }

  
  final GlobalKey<MapViewState> key = new GlobalKey<MapViewState>();
  List<Suggestion> suggestions = [];
  PlaceApiProvider apiClient;

  var sessionToken;
  var currentQuery = '';

  ///Overriding the default dispose() method to properly dispose of the search bar and the map view together.
  @override
  void dispose() {
    _controller.dispose();
    _searchBarController.dispose();
    super.dispose();
  }

  ///Builds our map view together with the floating search bar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MapView(key: key),
          _floatingSearchBar(),
        ],
      ),
    );
  }

  ///Populates the search bar with our intended styling
  Widget _floatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      hint: 'Search your destination carpark...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      maxWidth: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      clearQueryOnClose: false,
      transition: SlideFadeFloatingSearchBarTransition(),
      controller: _searchBarController,
      onQueryChanged: (query) {
        setState(() {
          currentQuery = query;
        });
      },
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      ///The builder to build out suggestions
      builder: (context, transition) {
        return _autocompleteSuggestionBuilder(context);
      },
    );
  }

  ///The FutureBuilder returns a widget corresponding to the state of completion of the Future. The Future we call here is to fetch suggestions from the apiClient (the PlaceService).
  ///
  /// If the query is empty, we show the presearch widget to tell the user to start typing.
  ///
  /// If the query has returned with an error, we show an error widget telling the user that the API is down.
  ///
  /// If the query has not returned, we show a loading widget.
  ///
  /// If the query has returned with results, we build the suggestions list.
  ///
  /// If the query has return with no results, we show the empty results widget.
  FutureBuilder<List<Suggestion>> _autocompleteSuggestionBuilder(
      BuildContext context) {
      return FutureBuilder(
        future: apiClient.fetchSuggestions(
            currentQuery, Localizations
            .localeOf(context)
            .languageCode),
        builder: (context, snapshot) {
          if (currentQuery == '') {
            return _preSearchWidget();
          }
          if (snapshot.hasData == false) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasError)
              return _errorResultsWidget();
            return _searchLoadingWidget();
          } else if (snapshot.data.length > 0) {
            return _suggestionListViewWidget(snapshot);
          } else {
            return _emptyResultsWidget();
          }
        },
      );
  }

  ///Suggests to the user to start typing to start the autocomplete.
  Widget _preSearchWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text('Start typing to search...'),
      ),
      color: Colors.white,
      constraints: BoxConstraints.expand(width: 380, height: 50),
    );
  }


  ///Tells the user the autocomplete is still loading results.
  Widget _searchLoadingWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text('Loading...'),
      ),
      color: Colors.white,
      constraints: BoxConstraints.expand(width: 380, height: 50),
    );
  }

  ///Builds out the suggestion list.
  Widget _suggestionListViewWidget(AsyncSnapshot<List<Suggestion>> snapshot) {
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(snapshot.data[index].description),
        onTap: () async {
          geo.LatLng location = await apiClient
              .getPlaceLatLngFromId(snapshot.data[index].placeId);

          Map<String, double> dataMap = {
            'latitude': location.latitude,
            'longitude': location.longitude,
            'accuracy': 0,
            'altitude': 0,
            'speed': 0,
            'speed_accuracy': 0,
            'heading': 0,
            'time': 0,
          };
          LocationData updated = LocationData.fromMap(dataMap);
          LocationManager.intendedLocation = updated;

          key.currentState.zoomToLocation(location);
          key.currentState
              .addMarkerForLocation(snapshot.data[index].description, location);
          _searchBarController.close();

        },
        tileColor: Colors.white,
      ),
      itemCount: snapshot.data.length,
      shrinkWrap: true,
    );
  }

  ///Tells the user that their search returned no results.
  Widget _emptyResultsWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text('No results found. Did you misspell your location?'),
      ),
      color: Colors.white,
      constraints: BoxConstraints.expand(width: 380, height: 50),
    );
  }

  ///Tells the user that the server is down. Likely that the API is down or the API key has expired.
  Widget _errorResultsWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text('Unable to connect to the server. Please try again.'),
      ),
      color: Colors.white,
      constraints: BoxConstraints.expand(width: 380, height: 50),
    );
  }
}
