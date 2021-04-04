import 'package:flutter_test/flutter_test.dart';
import 'package:park_buddy/control/PullDateManager.dart';
// to run:
// In terminal, input flutter run test/boundary_test_PullDateManager.dart
void main() async{
  //TestWidgetsFlutterBinding.ensureInitialized();
  // Valid Boundary EC: {0,24}
  // Invalid Boundary EC: {25}
  // Error Boundary EC: {-1}
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test("Valid Boundary: 0 Hours Since Last Pull Test", () async {
    DateTime now = new DateTime.now().toUtc().add(Duration(hours:8));
    await PullDateManager.saveDate(now.millisecondsSinceEpoch);
    int result = await PullDateManager.pullMissingDates();
    expect(result, 0);
  });

  test("Valid Boundary: 24 Hours Since Last Pull Test", () async {
    DateTime now = new DateTime.now().toUtc().add(Duration(hours:8));
    now = now.subtract(Duration(hours: 24));
    await PullDateManager.saveDate(now.millisecondsSinceEpoch);
    int result = await PullDateManager.pullMissingDates();
    expect(result, 24);
  });

  test("Invalid Boundary: 25 Hours Since Last Pull Test", () async {
    DateTime now = new DateTime.now().toUtc().add(Duration(hours:8));
    now = now.subtract(Duration(hours: 26));
    await PullDateManager.saveDate(now.millisecondsSinceEpoch);
    int result = await PullDateManager.pullMissingDates();
    expect(result, 24);
  });

  test("Invalid Boundary: -1 Hours Since Last Pull Test", () async {
    DateTime now = new DateTime.now().toUtc().add(Duration(hours:8));
    now = now.add(Duration(hours: 1));
    await PullDateManager.saveDate(now.millisecondsSinceEpoch);
    int result = await PullDateManager.pullMissingDates();
    expect(result, 24);
  });
}
