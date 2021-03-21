import 'package:flutter/material.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';


class CarparkCard extends StatelessWidget {
  final CarparkInfo carpark;
  CarparkCard({this.carpark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundImage: AssetImage('assets/images/parking-icon.png'),
          ),
          title: Text(carpark.carparkCode),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                carpark.address,
                style: TextStyle(fontSize: 15.0),
              ),
              Text(
                'Availability Goes here: 95/100',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
