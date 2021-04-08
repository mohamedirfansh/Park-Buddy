import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:park_buddy/control/DatabaseManager.dart';
import 'package:park_buddy/control/PullDateManager.dart';

import 'package:syncfusion_flutter_charts/charts.dart';


///This class is responsible for showing the historical carpark information for the previous week in an easy to read interface.
class Histogram extends StatefulWidget {
  @override
  _HistogramState createState() => _HistogramState(carparkCode);
  final carparkCode;
  Histogram(this.carparkCode);
}

///The state class for the Histogram.
class _HistogramState extends State<Histogram> {
  _HistogramState(this.carparkCode);
  final carparkCode;

  ///Defaults to the current day.
  String selectedDay = _getCurrentDayFromDateTime();

  ///Builds a histogram widget with a dropdown menu to change the day being viewed.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Carpark History", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              _dropdownMenu(),
            ],
          )
        ),
        _histogram()
      ],
    );
  }

  ///The histogram itself.
  Widget _histogram() {
    return FutureBuilder(
        future: _getHistogramData(carparkCode),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: SfCartesianChart(
                series: <ChartSeries>[
                  ColumnSeries<dynamic, DateTime>(
                    dataSource: snapshot.data[selectedDay],
                    xValueMapper: (dynamic carpark, _) {
                      return DateTime.fromMillisecondsSinceEpoch(carpark.timestamp);
                    },
                    yValueMapper: (dynamic carpark, _) {
                      return 100*(carpark.lotsAvailableC/carpark.totalLotsC);
                    },
                    pointColorMapper: (dynamic carpark, _) {
                      var fraction = carpark.lotsAvailableC /
                          carpark.totalLotsC;
                      return _availabilityToColor(fraction);
                    },
                    width: 0.8,
                  )
                ],
                primaryXAxis: DateTimeAxis(
                  majorGridLines: MajorGridLines(
                      width: 0,
                  ),
                  minorGridLines: MinorGridLines(
                      width: 0
                  ),
                    plotBands: insertCurrentTimePlotBand(selectedDay),
                ),
                primaryYAxis: NumericAxis(
                    labelFormat: '{value}% empty',
                    majorGridLines: MajorGridLines(
                      width: 0,
                    ),
                    minorGridLines: MinorGridLines(
                        width: 0
                    ),
                ),
                backgroundColor: Colors.transparent,
                plotAreaBackgroundColor: Colors.transparent,

              ),
            );
          } else return Container( child: SpinKitRing(
            color: Colors.cyan[300],
            size: 50.0,
            ),
          );
        }
    );
  }

  ///Converts the availability to a colour for each band of the histogram.
  ///
  /// @param availability The carpark's availability (Maximum 1.) Higher means more empty.
  Color _availabilityToColor(double availability){
      if (availability < 0.3) {
        return Colors.red;
      } else if ( availability < 0.5)
      {
        return Colors.deepOrange;
      } else if (availability < 0.7) {
        return Colors.amber;
      } else return Colors.green;
  }

  ///The widget to select the day of the week to view from the histogram.
  Widget _dropdownMenu() {
    return DropdownButton<String>(
      value: selectedDay,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          selectedDay = newValue;
        });
      },
      items: <String>['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
            value: value,
            child: Text(value)
        );
      }).toList(),
    );
  }


  ///Inserts a PlotBand for the current day of the week. If we are viewing another day, return null.
  List<PlotBand> insertCurrentTimePlotBand(String selectedDay){
    if (selectedDay == _getCurrentDayFromDateTime()) {
      return [
        PlotBand(
            isVisible: true,
            start: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                DateTime.now().hour
            ),
            end: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                DateTime.now().hour
            ),
            text: 'Current time',
            verticalTextPadding:'40%',
            horizontalTextPadding: '-15%',
            textStyle: TextStyle(color: Colors.black, fontSize: 16),
            borderWidth: 2,
            textAngle: 0,
            borderColor: Colors.lightBlue
        )
      ];
    } else {
      return null;
    }
  }

  ///Filters the carparkAvailability for dates that are in the future for the current day, as it shows a disjointed histogram otherwise.
  List<dynamic> _filterCarparkAvailability(List<dynamic> carparkList) {
    carparkList.forEach( (carpark) {
        if (carpark.timestamp < DateTime.now().millisecondsSinceEpoch - Duration(days: 1).inMilliseconds){
          carpark.timestamp += Duration(days: 7).inMilliseconds;
        }
    });
    return carparkList;
  }

  ///Gets the histogram data from the database and
  Future _getHistogramData(String carparkCode) async {
    await PullDateManager.pullMissingDates();
    Map<dynamic, dynamic> data = await DatabaseManager.getCarparkList(carparkCode);
    data[_getCurrentDayFromDateTime()] = _filterCarparkAvailability(data[_getCurrentDayFromDateTime()]);
    return data;
  }

  static String _getCurrentDayFromDateTime() {
    switch (DateTime.now().weekday) {
      case 1:
        return 'Mon';
        break;
      case 2:
        return 'Tues';
        break;
      case 3:
        return 'Wed';
        break;
      case 4:
        return 'Thurs';
        break;
      case 5:
        return 'Fri';
        break;
      case 6:
        return 'Sat';
        break;
      case 7:
        return 'Sun';
        break;
      default:
        return 'Mon';
    }
  }

}