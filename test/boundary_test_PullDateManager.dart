import 'package:flutter_test/flutter_test.dart';
import 'package:park_buddy/control/PullDateManager.dart';
// to run:
// In terminal, input flutter run test/boundary_test_PullDateManager.dart
void main() async{
  //TestWidgetsFlutterBinding.ensureInitialized();
  // Valid Boundary EC: {0,168}
  // Invalid Boundary EC: {169}
  // Error Boundary EC: {-1}
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  await test("Valid Boundary: 0 Hours Since Last Pull Test", () async {
    DateTime now = new DateTime.now().toUtc().add(Duration(hours:8));
    await PullDateManager.saveDate(now.millisecondsSinceEpoch);
    int result = await PullDateManager.pullMissingDates();
    expect(result, 0);
  });

  await test("Valid Boundary: 168 Hours Since Last Pull Test", () async {
    DateTime now = new DateTime.now().toUtc().add(Duration(hours:8));
    now = now.subtract(Duration(hours: 168));
    await PullDateManager.saveDate(now.millisecondsSinceEpoch);
    int result = await PullDateManager.pullMissingDates();
    expect(result, 168);
  });

  await test("Invalid Boundary: 169 Hours Since Last Pull Test", () async {
    DateTime now = new DateTime.now().toUtc().add(Duration(hours:8));
    now = now.subtract(Duration(hours: 169));
    await PullDateManager.saveDate(now.millisecondsSinceEpoch);
    int result = await PullDateManager.pullMissingDates();
    expect(result, 168);
  });

  await test("Invalid Boundary: -1 Hours Since Last Pull Test", () async {
    DateTime now = new DateTime.now().toUtc().add(Duration(hours:8));
    now = now.add(Duration(hours: 1));
    await PullDateManager.saveDate(now.millisecondsSinceEpoch);
    int result = await PullDateManager.pullMissingDates();
    expect(result, 168);
  });
}

