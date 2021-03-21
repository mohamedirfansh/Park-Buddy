import 'package:shared_preferences/shared_preferences.dart';

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

  static pullMissingDates() async {
    int lastDate = await getDate();

    final DateTime now = new DateTime.now().toUtc().add(Duration(hours:8)); // convert to SGT
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(lastDate);

    final Duration delta = Duration(minutes: 30); // round to nearest 30 minutes
    DateTime nearestHour = DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - now.millisecondsSinceEpoch % delta.inMilliseconds);
    if (nearestHour.minute == 0)
      nearestHour = nearestHour.subtract(Duration(minutes:30));
    final int difference = nearestHour.difference(date).inHours; // get the difference between current time and last recorded date.
    final int saved = nearestHour.millisecondsSinceEpoch; // save the time so that we can store it later as reference

    int pulls = (difference > _pullWindow) ? _pullWindow : difference; // if difference > pullWindow, means last pull was outside the window, and we need to do a complete pull.

    await DatabaseManager.deleteAllCarparkBefore(nearestHour.subtract(Duration(hours:_pullWindow))); // delete all records outside the window
    /*
    for (int i=0;i<pulls;i++) {
      DatabaseManager.pullCarparkAvailability(nearestHour, insertIntoDatabase: true);
      nearestHour = nearestHour.subtract(Duration(hours: 1));
    }
     */
    List<DateTime> pullList = new List<DateTime>();
    pullList.add(nearestHour);
    DateTime dec = new DateTime(nearestHour.year,nearestHour.month,nearestHour.day,nearestHour.hour,nearestHour.minute); // clone nearest hour for increment purposes
    for (int i=1;i<pulls;i++) {
      dec = dec.subtract(Duration(hours: 1));
      pullList.add(dec);
    }
    await Future.wait(pullList.map((e) => DatabaseManager.pullCarparkAvailability(e, insertIntoDatabase: true))); // pull async, since we don't care about the order
    saveDate(saved);
  }
}