import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getHistogramData(carparkCode),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            snapshot.data.forEach( (k,v) => print('$k: ${v.length}'));
            return Container(child: Text("Loaded"));



            // return AspectRatio(
            //   aspectRatio: 1.7,
            //   child: Card(
            //       elevation: 0,
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            //       //color: const Color(0xff2c4260),
            //       child:  SfCartesianChart(
            //               series: <ChartSeries>[
            //               HistogramSeries<CarparkAvailability, num>(
            //               dataSource: snapshot.data,
            //               yValueMapper: (CarparkAvailability carpark, _) => sales.yValue,
            //               binInterval: 20,
            //               showNormalDistributionCurve: true,
            //               curveColor: const Color.fromRGBO(192, 108, 132, 1),
            //               borderWidth: 3,
            //               animationDuration: 1000,
            //           ),
            //         ),
            //       );

          } else return Container(child: Text("Loading"),);
        }
    );

  }

  Future _getHistogramData(String carparkCode) async {
    await PullDateManager.pullMissingDates();
    return await DatabaseManager.getCarparkList(carparkCode);
  }

  void convertDatabaseInfoToChart() {

  }

}

//TODO: load data from some database/CSV