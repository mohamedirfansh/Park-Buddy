import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

///Displays screenshots of the app with instructions to show how to use the app.
/// {@category Boundary}
class OnBoardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: 'Parking lots',
              body: 'Tap on carpark pin to view address and lot type',
              image: buildImage('assets/images/carparks_near.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Search destination',
              body:
              'Search for a location to find carparks near your destination',
              image: buildImage('assets/images/search.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Select the perfect parking lot',
              body:
              'Tap on the carpark pin label or card in List View to view carpark info like lot availability, distance & historic availability',
              image: buildImage('assets/images/info_page.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Get directions',
              body: 'Get automatic directions to the carpark via Google Maps',
              image: buildImage('assets/images/directions.png'),
              decoration: getPageDecoration(),
            ),
          ],
          done: Text(
            'Done',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onDone: () => goToHome(context),
          showSkipButton: true,
          skip: Text('Skip'),
          onSkip: () => goToHome(context),
          next: Icon(Icons.arrow_forward),
          dotsDecorator: getDotDecoration(),
        ),
      );

  ///Prevents user from going back to tutorial using the navigation back bar, by replacing the route instead of adding to the route.
  void goToHome(context) =>
      Navigator.pushReplacementNamed(context, '/multitabview');

  ///Builds an image from an asset to display on the tutorial screens.
  Widget buildImage(String path) =>
      Center(child: Image.asset(path, width: 350));

  ///Describes the style of the tutorial pages
  PageDecoration getPageDecoration() => PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 20),
        descriptionPadding: EdgeInsets.all(16).copyWith(bottom: 0),
        imagePadding: EdgeInsets.all(24),
        pageColor: Colors.white,
      );

  ///Describes the style of the navigation buttons in our tutorial
  DotsDecorator getDotDecoration() => DotsDecorator(
        color: Color(0xFFBDBDBD),
        size: Size(10, 10),
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      );
}
