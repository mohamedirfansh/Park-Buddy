import 'package:flutter/material.dart';
import 'package:park_buddy/control/ScreenManager.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';


class CarparkCard extends StatelessWidget {
  final CarparkInfo carpark;
  final CarparkAvailability carparkAvailability;
  bool hasError = false;
  CarparkCard(this.carpark, this.carparkAvailability, this.hasError);

  @override
  Widget build(BuildContext context) {
    if (carparkAvailability != null && !hasError) {
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
                  "${carparkAvailability.lotsAvailableC}/${carparkAvailability.totalLotsC} lots available",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            onTap: () => ScreenManager.openDynamicInfoPage(context, carpark.carparkCode, carparkAvailability),
          ),
        ),
      );
    } else if (hasError) {
      return _errorCard(context);
    }
    return _missingAvailabilityCard();
  }

  Widget _missingAvailabilityCard(){
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
                "Loading lot availability...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorCard(var context){
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
                "Lot Availability Unavailable",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onTap: () => ScreenManager.openDynamicInfoPage(context, carpark.carparkCode, carparkAvailability),
        ),
      ),
    );
  }
}
