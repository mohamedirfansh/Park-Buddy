import 'package:flutter/material.dart';
import 'package:park_buddy/boundary/CarparkListView.dart';
import 'package:park_buddy/control/MapViewWithSearch.dart';

class TabNavigationItem {
  final Widget page;
  final String title;
  final Icon icon;

  TabNavigationItem({
    @required this.page,
    @required this.title,
    @required this.icon,
  });

  static List<TabNavigationItem> get items => [
        TabNavigationItem(
          page: MapViewWithSearch(),
          icon: Icon(Icons.map_rounded),
          title: "Map View",
        ),
        TabNavigationItem(
          page: CarparkListView(),
          icon: Icon(Icons.list),
          title: "List View",
        ),
      ];
}
