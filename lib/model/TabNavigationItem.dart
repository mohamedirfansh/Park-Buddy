import 'package:flutter/material.dart';
import 'package:park_buddy/map.dart';
import 'package:park_buddy/view/CarparkListView.dart';

class TabNavigationItem {
  final Widget page;
  final Widget title;
  final Icon icon;

  TabNavigationItem({
    @required this.page,
    @required this.title,
    @required this.icon,
  });

  static List<TabNavigationItem> get items => [
        TabNavigationItem(
          page: MapView(),
          icon: Icon(Icons.map_rounded),
          title: Text("Map View"),
        ),
        TabNavigationItem(
          page: CarparkListView(),
          icon: Icon(Icons.list),
          title: Text("List View"),
        ),
      ];
}
