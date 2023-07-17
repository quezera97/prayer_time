import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prayer_time/ui/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_overseas.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => StartState();
}

class StartState extends State<SplashScreen> {
  ImageProvider preloadImage = const AssetImage('assets/img/splashscreen.png');

  bool prefsInMalaysia = true;
  bool? inMalaysia;

  @override
  void initState() {
    super.initState();
    _getInitPrefs();
  }

  _getInitPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefsInMalaysia = prefs.getBool('prefsInMalaysia')!;

    setState(() {
      inMalaysia = prefsInMalaysia;
    });

    await _startTime(inMalaysia);
  }

  _startTime(inMalaysia) async {
    var duration = const Duration(seconds: 4);

    if(inMalaysia){
      return Timer(duration, routeDashboardMain);
    }
    else{
      return Timer(duration, routeDashboardOversea);
    }
  }

  routeDashboardMain() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Dashboard()));
  }

  routeDashboardOversea() {
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => const DashboardOverseas()));
  } 

  @override
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
