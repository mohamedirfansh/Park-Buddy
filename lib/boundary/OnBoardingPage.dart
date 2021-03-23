import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: 'Parking lots',
              body: 'Find parking lots near you',
              //image: buildImage('assets/image.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Parking lots',
              body: 'Find parking lots near you',
              //image: buildImage('assets/image.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Parking lots',
              body: 'Find parking lots near you',
              //image: buildImage('assets/image.png'),
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
          globalBackgroundColor: Color(0xFF06E2B2),
        ),
      );

  void goToHome(context) => Navigator.pushNamed(context, '/multitabview');


  PageDecoration getPageDecoration() => PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 20),
        descriptionPadding: EdgeInsets.all(16).copyWith(bottom: 0),
        imagePadding: EdgeInsets.all(24),
        pageColor: Colors.white,
      );

  DotsDecorator getDotDecoration() => DotsDecorator(
        color: Color(0xFFBDBDBD),
        size: Size(10, 10),
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      );
}
