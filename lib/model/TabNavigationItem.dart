import 'package:flutter/material.dart';
import 'package:test_app/map.dart';
import 'package:test_app/view/CarparkListView.dart';

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
