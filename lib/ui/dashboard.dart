// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time/api/location_time_zone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/today_prayer_time.dart';
import '../zone/widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {  
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  String hijri = '';
  String date = '';
  String day = '';

  String selectedValue = '';

  void initState() {
    checkGps();
    _loadPrayerTime(null);
    super.initState();
  }

  checkGps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    servicestatus = await Geolocator.isLocationServiceEnabled();

    await prefs.setBool('prefsServiceStatus', servicestatus);

    if(servicestatus){
      permission = await Geolocator.checkPermission();
    
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          haspermission = false;
        }
        else if(permission == LocationPermission.deniedForever){
          haspermission = false;
        }
        else{
          haspermission = true;
        }
      }
      else{
        haspermission = true;
      }

      await prefs.setBool('prefsHasPermission', haspermission);

      if(haspermission){
        getLocation();
      }
    }
    else{
      servicestatus = false;
    }
  }

  getLocation() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a 
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      long = position.longitude.toString();
      lat = position.latitude.toString();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('prefsLongitude', long);
    await prefs.setString('prefsLatitude', lat);
    
    _loadTimeZone(long, lat);
  }

  Future<void> _loadTimeZone(String long, String lat) async {
    try {
      var timeZone = await fetchTimeZone(long, lat);

      print(timeZone);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadPrayerTime(zone) async {
    if(zone != null){
      try {
        var prayerTime = await fetchPrayerTime(zone);

        setState(() {
          hijri = prayerTime['hijri'];
          date = prayerTime['date'];
          day = prayerTime['day'];
          // imsak = prayerTime['imsak'];
          // fajr = prayerTime['fajr'];
          // syuruk = prayerTime['syuruk'];
          // dhuhr = prayerTime['dhuhr'];
          // asr = prayerTime['asr'];
          // maghrib = prayerTime['maghrib'];
          // isha = prayerTime['isha'];
        });
      } catch (e) {
        // Handle error
        print(e);
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Waktu Solat',
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: servicestatus == true 
                ? const Icon(
                  Icons.gps_fixed,
                  color: Colors.white,
                )
                : const Icon(
                  Icons.gps_off,
                  color: Colors.white,
                ),
                onPressed: () async {
                  checkGps();
                },
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
                color: Color.fromARGB(255, 233, 109, 200),
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
              ),
              title: const Text('Page 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.train,
              ),
              title: const Text('Page 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              if(haspermission == false) ... [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 100,
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Column(
                            children: [
                              Text('Hijri: $hijri'),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Day: $day'),
                                  const SizedBox(width: 30),
                                  Text('Date: $date')
                                ],
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ]
              else ... {
                const StatesZonesDropdownWidget(),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      String? zone = prefs.getString('prefsZone');

                      if(zone != null){
                        fetchPrayerTime(zone);
                      }
                      else{
                        showDialog(
                          context: context,
                          builder: (context) => _buildLogoutConfirmationDialog(context),
                        ); 
                      }
                    },
                    child: const Text('Pilih'),
                  ),
                ),
              }                  
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildLogoutConfirmationDialog(BuildContext context) {
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
            'Amaran!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Sila Pilih Zon',
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
