import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prayer_time/ui/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  State<StatefulWidget> createState() => StartState();
}

class StartState extends State<SplashScreen> {
  ImageProvider preloadImage = const AssetImage('assets/img/splashscreen.png');

  void initState() {
    super.initState();
    _startTime();
  }

  _startTime() async {
    var duration = const Duration(seconds: 4);
    return Timer(duration, routeDashboardMain);
  }

  routeDashboardMain() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Dashboard()));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff764abc),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: preloadImage,
                  // width: 100,
                  // height: 100,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
