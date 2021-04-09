import 'package:park_buddy/boundary/CarparkAPIInterface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:semaphore/semaphore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


import 'DatabaseManager.dart';

/// Handles the logic to pull dates that are missing from the database and delete dates that are outside the window.
class PullDateManager{
  /// Defines the timeframe that we maintain the historical data for. (i.e. pullWindow = 24; historical data for the past 24 hours will be maintained.)
  static final int _pullWindow = 3*24; // 1 day
  static ValueNotifier<double> progressNotifier = ValueNotifier(0);
  static final _sm = LocalSemaphore(1);

  static Future<int> getDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lastDate = await prefs.getInt('date') ?? 0; // handle null value
    return lastDate;
  }

  static saveDate(int lastEpochDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('date', lastEpochDate);
  }

  static resetDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('date', 0);
  }

  static _updateProgress(int count, int pull) {
    var result = count/pull;
    progressNotifier.value = result;
  }

  static Future<List<T>> _progressWait<T>(List<Future<T>> futures) {
    int total = futures.length;
    int completed = 0;
    void complete() {
      completed++;
      _updateProgress(completed, total);
    }
    return Future.wait<T>([for (var future in futures) future.whenComplete(complete)]);
  }

  static Future<int> pullMissingDates() async {
    int pulls = 0;
    try {
      await _sm.acquire();
      int lastDate = await getDate();
      tz.initializeTimeZones();
      final locationSG = tz.getLocation('Asia/Singapore');
      final DateTime now = tz.TZDateTime.now(locationSG);
      //final DateTime now = new DateTime.now(); // convert to SGT
      final DateTime date = tz.TZDateTime.fromMillisecondsSinceEpoch(locationSG, lastDate);

      final Duration delta = Duration(
          minutes: 30); // round to nearest 30 minutes
      DateTime nearestHour = tz.TZDateTime.fromMillisecondsSinceEpoch(locationSG,
          now.millisecondsSinceEpoch -
              now.millisecondsSinceEpoch % delta.inMilliseconds);
      if (nearestHour.minute == 0)
        nearestHour = nearestHour.subtract(Duration(minutes: 30));
      int difference = nearestHour
          .difference(date)
          .inMinutes; // get the difference between current time and last recorded date.
      difference = (difference / 60).ceil();
      final int saved = nearestHour
          .millisecondsSinceEpoch; // save the time so that we can storpue it later as reference
      pulls = (difference >= _pullWindow || difference < 0)
          ? _pullWindow
          : difference; // if difference >= pullWindow, means last pull was outside the window, and we need to do a complete pull.
      if (pulls >= _pullWindow) await DatabaseManager.deleteAllCarparkBefore(
          now); // delete all records if need to do a complete pull
      else {
        await DatabaseManager.deleteAllCarparkBefore(
            nearestHour.subtract(Duration(hours: _pullWindow)).add(Duration(
                minutes: 15)));
      }// delete all records outside the window otherwise
      List<DateTime> pullList = <DateTime>[];
      if (pulls > 0) {
        pullList.add(nearestHour);
        DateTime dec = new DateTime(
            nearestHour.year, nearestHour.month, nearestHour.day,
            nearestHour.hour,
            nearestHour.minute); // clone nearest hour for increment purposes
        for (int i = 1; i < pulls; i++) {
          dec = dec.subtract(Duration(hours: 1));
          pullList.add(dec);
        }
        try {
          var list = (pullList.map((e) =>
              DatabaseManager.pullCarparkAvailability(e,
                  insertIntoDatabase: true)))
              .toList(); // pull async, since we don't care about the order
          await _progressWait(list);
        } on DatabaseException catch (e) {
          print(e);
          resetDate(); // if error during insertion, reset the pull date and do a pull from scratch the next time around
        } on BadRequestException {
          // test case exception
        } catch (e) {
          print(e);
          _sm.release();
          throw Exception("Cannot connect to API");
        }
      }
      saveDate(saved);
    } finally {
      _sm.release();
    }
    return pulls;
  }
}