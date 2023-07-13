// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time/api/location_time_zone.dart';
import 'package:prayer_time/settings/settings.dart';
import 'package:prayer_time/ui/muazzin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/alert_pop_up.dart';
import '../components/loading_indicator.dart';
import '../zone/widget.dart';
import '../zone/options.dart';
import 'prayer_time.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool serviceStatus = false;
  bool requestPermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;
  
  String? prefsLongitude;
  String? prefsLatitude;

  String selectedValue = '';

  String? stateZone;
  String? prefsStateZone;

  String? zone;
  String? prefsZone;

  bool loadingScreen = true;

  @override
  void initState() {
    _getInitPrefs(); 

    super.initState();
  }

  Future<void> _getInitPrefs() async {
    await _checkGps();
  }

  Future<void> _checkGps() async {
    serviceStatus = await Geolocator.isLocationServiceEnabled();
  
    if(serviceStatus){
      permission = await Geolocator.checkPermission();
    
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          requestPermission = false;
        }
        else if(permission == LocationPermission.deniedForever){
          requestPermission = false;
        }
        else{
          requestPermission = true;
        }
      }
      else{
        requestPermission = true;
      }

      if(requestPermission == true){
        await _getLocation();
      }
      else{
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefsZone = prefs.getString('prefsZone');
        prefsStateZone = prefs.getString('prefsStateZone');
        prefsLongitude = prefs.getString('prefsLongitude');
        prefsLatitude = prefs.getString('prefsLatitude');

        setState(() {
          zone = prefsZone;
          stateZone = prefsStateZone;

          loadingScreen = false;

          if(prefsLongitude != null && prefsLatitude != null){
            long = prefsLongitude!;
            lat = prefsLatitude!;
          }
        });

        if(long.isNotEmpty && lat.isNotEmpty){
          await _loadTimeZone(long, lat);
        }
      }
    }
    else{
      serviceStatus = false;
    }

    setState(() {
      serviceStatus;
      requestPermission;
    });
  }

  Future<void> _getLocation() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: locationSettings.accuracy,
    );

    long = position.longitude.toString();
    lat = position.latitude.toString();

    // getPositionStream method is used to listen to position updates continuously.
    // Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
    //   long = position.longitude.toString();
    //   lat = position.latitude.toString();
    // });

    await _loadTimeZone(long, lat);
  }

  Future<void> _loadTimeZone(String long, String lat) async {
    try {

      stateZone = await fetchTimeZone(long, lat);      

      String matchingZone = '';
      
      for (var zoneOption in allZoneOptions) {
        if (zoneOption['text']!.toLowerCase().contains(stateZone!.toLowerCase())) {
          matchingZone = zoneOption['value']!;
          break;
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('prefsZone', matchingZone);
      await prefs.setString('prefsStateZone', stateZone!);
      await prefs.setString('prefsLongitude', long);
      await prefs.setString('prefsLatitude', lat);

      setState(() {
        stateZone;
        loadingScreen = false;
      });

    } catch (e) {
      AlertPopUp(
        titleAlert: 'Error!', 
        contentAlert: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Waktu Solat',
        ),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  _checkGps();
                },
                icon: const Icon( Icons.gps_fixed, color: Colors.white )
              )
            ],
          )
        ],
        backgroundColor: const Color(0xff764abc),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff764abc),
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              leading: const Icon(
                Icons.person_4_sharp,
              ),
              title: const Text('Muazzin'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Muazzin()),
                );
              },
            ),
            const Divider(
              thickness: 0.25,
              color: Colors.grey,
              indent: 20,
              endIndent: 20,
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
              ),
              title: const Text('Setting'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
              },
            ),
            const Divider(
              thickness: 0.25,
              color: Colors.grey,
              indent: 20,
              endIndent: 20,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(          
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              if(loadingScreen == false) ... [
                if (stateZone == null) ... [                  
                  const StatesZonesDropdownWidget(),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();

                        prefsZone = prefs.getString('prefsZone');
                        prefsStateZone = prefs.getString('prefsStateZone');

                        if(prefsZone != null){
                          setState(() {
                            zone = prefsZone;
                            stateZone = prefsStateZone;
                          });
                        }
                        else{
                          showDialog(
                            context: context,
                            builder: (context) => _buildConfirmationDialog(context),
                          ); 
                        }
                      },
                      child: const Text('Choose'),
                    ),
                  ),
                ]
                else if(stateZone != null) ... [   
                  const PrayerTime(),
                ]
                else ... [
                  loadingGifIndicator( gif: 'assets/img/loading.gif', message: 'Loading data...'),
                ]
              ]
              else ... [
                loadingGifIndicator( gif: 'assets/img/loading.gif', message: 'Loading data...'),
              ]
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on, color: Colors.black54,
            ),
            Text( 
              stateZone ?? '',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildConfirmationDialog(BuildContext context) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Warning!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Please Choose Zone',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
