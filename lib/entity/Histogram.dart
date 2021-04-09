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

  Widget _loading() {
    return Container(
      child: LinearProgressIndicator(
        value: 0,
      ),
    );
  }

  ///The histogram itself.
  Widget _histogram() {
    DateTime now = DateTime.now();
    int day = now.day;
    int month = now.month;
    int year = now.year;
    return FutureBuilder(
        future: _getHistogramData(carparkCode),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: SfCartesianChart(
                series: <ChartSeries>[
                  ColumnSeries<dynamic, DateTime>(
                    dataSource: snapshot.data[selectedDay],
                    trendlines:<Trendline>[
                      Trendline(
                        type: TrendlineType.movingAverage,
                        backwardForecast: 10,
                        dashArray: <double>[5,5],
                        color: Colors.black,
                        width: 3,
                        opacity: 0.6,
                      )
                    ],
                    xValueMapper: (dynamic carpark, _) {
                      DateTime val = DateTime.fromMillisecondsSinceEpoch(carpark.timestamp);
                      day = val.day;
                      month = val.month;
                      year = val.year;
                      return val;
                    },
                    yValueMapper: (dynamic carpark, _) {
                      return 100*(carpark.lotsAvailableC/carpark.totalLotsC);
                    },
                    pointColorMapper: (dynamic carpark, _) {
                      var fraction = carpark.lotsAvailableC /
                          carpark.totalLotsC;
                      return _availabilityToColor(fraction);
                    },
                    width: 0.8, // Width of the columns
                    // animationDuration: 1000,// Spacing between the column
                  )
                ],
                primaryXAxis: DateTimeAxis(
                  minimum:DateTime(year,month,day,0),
                  maximum:DateTime(year,month,day,24),

                  majorGridLines: MajorGridLines(
                    width: 0,
                  ),
                  minorGridLines: MinorGridLines(
                      width: 0
                  ),
                  plotBands: selectedDay == _getCurrentDayFromDateTime() ? <PlotBand>[
                    PlotBand(
                        isVisible: true,
                        start: DateTime(
                            now.year,
                            now.month,
                            now.day,
                            now.hour
                        ),
                        end: DateTime(
                            now.year,
                            now.month,
                            now.day,
                            now.hour
                        ),
                        text: 'Current time',
                        verticalTextPadding:'40%',
                        horizontalTextPadding: '-15%',
                        textStyle: TextStyle(color: Colors.black, fontSize: 16),
                        borderWidth: 2,
                        textAngle: 0,
                        borderColor: Colors.lightBlue
                    )
                  ] : null,
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 100,
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
          } else return Container(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 10),

              child: Column(
                children: [
                  SpinKitRing(
                    color: Colors.cyan[300],
                    size: 50.0,
                  ),
                  Text("Loading carpark history...",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),),
                  ValueListenableBuilder(
                  valueListenable: PullDateManager.progressNotifier,
                  builder: (BuildContext context, double progress, Widget child) {
                    return LinearProgressIndicator(
                        value: progress,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan[300]),
                        backgroundColor: Colors.white,
                        minHeight: 10,
                      );
                  }),
                  ],

              )
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
    DateTime now = DateTime.now();
    if (selectedDay == _getCurrentDayFromDateTime()) {
      return [
        PlotBand(
            isVisible: true,
            start: DateTime(
                now.year,
                now.month,
                now.day,
                now.hour,
                now.minute
            ),
            end: DateTime(
                now.year,
                now.month,
                now.day,
                now.hour,
                now.minute
            ),
            text: 'Current time',
            verticalTextPadding:'40%',
            horizontalTextPadding: DateTime.now().hour < 12 ? '-15%': '15%',
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
    carparkList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return carparkList;
  }

  ///Gets the histogram data from the database and processes it for histogram display
  Future _getHistogramData(String carparkCode) async {
    await PullDateManager.pullMissingDates();
    Map<dynamic, dynamic> data = await DatabaseManager.getCarparkList(carparkCode);
    data[_getCurrentDayFromDateTime()] = _filterCarparkAvailability(data[_getCurrentDayFromDateTime()]);
    return data;
  }

  ///Converts the int valeu of DateTime.now().weekday to a String for use in the Histogram.
  static String _getCurrentDayFromDateTime() {
    switch (DateTime.now().toUtc().weekday) {
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