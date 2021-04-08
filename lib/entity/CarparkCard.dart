import 'package:flutter/material.dart';
import 'package:park_buddy/control/ScreenManager.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';

///This is a UI class for showing carparks in the CarparkListView using the data provided in the constructor.
class CarparkCard extends StatelessWidget {
  final CarparkInfo carpark;
  final CarparkAvailability carparkAvailability;
  CarparkCard(this.carpark, this.carparkAvailability);

  ///Builds the CarparkCard widget.
  @override
  Widget build(BuildContext context) {
    if (carparkAvailability != null) {
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
    }
    return _missingAvailabilityCard();
  }

  ///If the carparkAvailability is missing, it means the API has not finished loading yet, so we show some loading text.
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
}
