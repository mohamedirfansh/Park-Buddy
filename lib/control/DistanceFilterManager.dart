import 'package:flutter/material.dart';
import 'package:park_buddy/boundary/CarparkListView.dart';
import 'package:park_buddy/control/CarparkListManager.dart';

typedef void DistCallBack(double dist);

class DistFilterManager extends StatefulWidget {
  @override
  _DistFilterManagerState createState() => _DistFilterManagerState();
}

class _DistFilterManagerState extends State<DistFilterManager> {
  final _formKey = GlobalKey<FormState>();
  final List<double> distance = [0.5, 1.0, 2.0, 5.0, 10.0];

  // final DistCallBack updateDist;
  // _DistFilterManagerState(this.updateDist);

  // Form values
  double _chosenDistance = 0.5;

  double chosenDist() {
    return _chosenDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(
            'How far should the carparks be?',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(
            height: 20.0,
          ),
          DropdownButtonFormField(
              //decoration:
              value: _chosenDistance ?? 0.5,
              items: distance.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text('$d km'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _chosenDistance = val;
                  print(_chosenDistance);
                });
              }),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            color: Color(0xFF06E2B3),
            child: Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                //updateDist(_chosenDistance);
                CarparkListView.of(context).distance = 0.7;
                print(_chosenDistance);
                //Navigator.pop(context);
              }
            },
          )
        ],
      ),
    );
  }
}
