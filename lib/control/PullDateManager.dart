import 'package:park_buddy/boundary/CarparkAPIInterface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'DatabaseManager.dart';

/// Handles the logic to pull dates that are missing from the database and delete dates that are outside the window.
class PullDateManager {
  /// Defines the timeframe that we maintain the historical data for. (i.e. pullWindow = 24; historical data for the past 24 hours will be maintained.)
  static final int _pullWindow = 1*24; // 1 day

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

  static Future<int> pullMissingDates() async {
    int lastDate = await getDate();

    final DateTime now = new DateTime.now().toUtc().add(Duration(hours:8)); // convert to SGT
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(lastDate);

    final Duration delta = Duration(minutes: 30); // round to nearest 30 minutes
    DateTime nearestHour = DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - now.millisecondsSinceEpoch % delta.inMilliseconds);
    if (nearestHour.minute == 0)
      nearestHour = nearestHour.subtract(Duration(minutes:30));
    int difference = nearestHour.difference(date).inMinutes; // get the difference between current time and last recorded date.
    difference = (difference/60).ceil();
    final int saved = nearestHour.millisecondsSinceEpoch; // save the time so that we can storpue it later as reference
    int pulls = (difference >= _pullWindow || difference < 0) ? _pullWindow : difference; // if difference >= pullWindow, means last pull was outside the window, and we need to do a complete pull.
    if (pulls >= _pullWindow) await DatabaseManager.deleteAllCarparkBefore(now); // delete all records if need to do a complete pull
    else await DatabaseManager.deleteAllCarparkBefore(nearestHour.subtract(Duration(hours:_pullWindow))); // delete all records outside the window otherwise
    List<DateTime> pullList = new List<DateTime>();
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
        await Future.wait(pullList.map((e) =>
            DatabaseManager.pullCarparkAvailability(e,
                insertIntoDatabase: true))); // pull async, since we don't care about the order
      } on DatabaseException catch(e){
          print(e);
          resetDate(); // if error during insertion, reset the pull date and do a pull from scratch the next time around
      } on BadRequestException {
        // test case exception
      } catch(e) {
        print(e);
        throw Exception("Cannot connect to API");
      }
    }
    saveDate(saved);
    return pulls;
  }
}