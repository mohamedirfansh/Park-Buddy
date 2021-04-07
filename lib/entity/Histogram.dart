import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:park_buddy/control/DatabaseManager.dart';
import 'package:park_buddy/control/PullDateManager.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

class Histogram extends StatefulWidget {
  @override
  _HistogramState createState() => _HistogramState(carparkCode);
  final carparkCode;
  Histogram(this.carparkCode);
}

class _HistogramState extends State<Histogram> {
  _HistogramState(this.carparkCode);
  final carparkCode;
  String selectedDay = _getCurrentDayFromDateTime();
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
                      var fraction = carpark.lotsAvailableC/carpark.totalLotsC;
                      if (fraction < 0.3) {
                        return Colors.red;
                      } else if ( fraction < 0.5)
                      {
                        return Colors.deepOrange;
                      } else if (fraction < 0.7) {
                        return Colors.amber;
                      } else return Colors.green;
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

  List<dynamic> _filterCarparkAvailability(List<dynamic> carparkList) {
    carparkList.forEach( (carpark) {
        if (carpark.timestamp < DateTime.now().millisecondsSinceEpoch - Duration(days: 1).inMilliseconds){
          carpark.timestamp += Duration(days: 7).inMilliseconds;
        }
    });
    return carparkList;
  }

  Future _getHistogramData(String carparkCode) async {
    await PullDateManager.pullMissingDates();
    Map<dynamic, dynamic> data = await DatabaseManager.getCarparkList(carparkCode);
    switch (DateTime.now().weekday) {
      case 1:
        data['Mon'] = _filterCarparkAvailability(data['Mon']);
        break;
      case 2:
        data['Tues'] = _filterCarparkAvailability(data['Tues']);
        break;
      case 3:
        data['Wed'] = _filterCarparkAvailability(data['Wed']);
        break;
      case 4:
        data['Thurs'] = _filterCarparkAvailability(data['Thurs']);
        break;
      case 5:
        data['Fri'] = _filterCarparkAvailability(data['Fri']);
        break;
      case 6:
        data['Sat'] = _filterCarparkAvailability(data['Sat']);
        break;
      case 7:
        data['Sun'] = _filterCarparkAvailability(data['Sun']);
        break;
    }
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
    }

    return 'Mon';
  }

}