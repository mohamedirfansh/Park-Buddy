import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:location/location.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:uuid/uuid.dart';

import 'package:park_buddy/boundary/MapView.dart';
import 'package:park_buddy/boundary/PlaceService.dart';

import 'LocationManager.dart';

class MapViewWithSearch extends StatefulWidget {
  @override
  _MapViewWithSearchState createState() => _MapViewWithSearchState();
}

class _MapViewWithSearchState extends State<MapViewWithSearch> {
  final _controller = TextEditingController();
  final _searchBarController = FloatingSearchBarController();
  _MapViewWithSearchState() {
    this.sessionToken = Uuid().v4();
    apiClient = PlaceApiProvider(sessionToken);
  }

  final GlobalKey<MapViewState> key = new GlobalKey<MapViewState>();
  List<Suggestion> suggestions = List<Suggestion>();
  PlaceApiProvider apiClient;

  var sessionToken;
  var currentQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MapView(key: key),
          buildFloatingSearchBar(),
        ],
      ),
    );
  }

  Widget buildFloatingSearchBar() {
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
      builder: (context, transition) {
        return _autocompleteSuggestionBuilder(context);
      },
    );
  }

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

  Widget _emptyResultsWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text('No results found.'),
      ),
      color: Colors.white,
      constraints: BoxConstraints.expand(width: 380, height: 50),
    );
  }

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
