import 'package:flutter/material.dart';

class CarparkInfoPage extends StatefulWidget {
  @override
  _CarparkInfoPageState createState() => _CarparkInfoPageState(this.carparkCode);
  final String carparkCode;
  CarparkInfoPage(this.carparkCode);
}

class _CarparkInfoPageState extends State<CarparkInfoPage> {
  _CarparkInfoPageState(this.carparkCode);
  final String carparkCode;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Text(carparkCode)),
      );
  }
}

//TODO: button to link to google maps app for directions (figure out function call from the default Marker onTap behaviour)
//TODO: histogram (queried on demand, show current time data)