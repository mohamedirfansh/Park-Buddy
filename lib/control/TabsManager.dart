import 'package:flutter/material.dart';
import 'package:park_buddy/entity/TabNavigationItem.dart';

///This class controls the view between the MapViewWithSearch and the CarparkListView by providing a BottomNavigationBar.
/// {@category Control}
class TabsManager extends StatefulWidget {
  @override
  _TabsManagerState createState() => _TabsManagerState();
}

class _TabsManagerState extends State<TabsManager> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (final tabItem in TabNavigationItem.items) tabItem.page,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
        items: [
          for (final tabItem in TabNavigationItem.items)
            BottomNavigationBarItem(
              icon: tabItem.icon,
              label: tabItem.title,
            )
        ],
      ),
    );
  }
}
