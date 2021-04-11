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
              title: 'Tap to Search',
              body: 'Tap on the Search Bar and type to search for a destination.',
              image: buildImage('assets/images/Search_Destination.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Select a destination',
              body:
              'Tap on a suggested location to select it as your destination. The map will show any nearby carparks around your chosen destination.',
              image: buildImage('assets/images/Select_Destination.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Swap Views',
              body:
              'Tap on the Map View or List View buttons on the bottom of the screen to swap between the Map and List Views.',
              image: buildImage('assets/images/Swap_Views.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Get More Information',
              body: 'Get more information about a specific carpark by tapping on a carpark pin label in the Map View, or a card in the List View.',
              image: buildImage('assets/images/View_Info.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Get directions',
              body: 'Tap on "Get Directions via Google Maps" to get navigation instructions from your current location to your selected destination.',
              image: buildImage('assets/images/Get_Directions.png'),
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
