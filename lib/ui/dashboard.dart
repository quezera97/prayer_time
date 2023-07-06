// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time/api/location_time_zone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/today_prayer_time.dart';
import '../zone/widget.dart';
import '../zone/options.dart';
import 'prayer_time.dart';
import '../components/popupMessage.dart' as pop_up;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {  
  bool serviceStatus = false;
  bool requestPermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  String? prefsLongitude;
  String? prefsLatitude;
  late StreamSubscription<Position> positionStream;

  String hijri = '';
  String date = '';
  String day = '';
  String imsak = '';
  String fajr = '';
  String syuruk = '';
  String dhuhr = '';
  String asr = '';
  String maghrib = '';
  String isha = '';

  String selectedValue = '';

  String? stateZone;

  String? zone;
  String? prefsZone;

  @override
  void initState() {
    _getInitPrefs();
    _checkGps();

    super.initState();
  }

  Future<void> _getInitPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefsZone = prefs.getString('prefsZone');
    prefsLongitude = prefs.getString('prefsLongitude');
    prefsLatitude = prefs.getString('prefsLatitude');

    if(prefsLongitude != null && prefsLatitude != null){
      await _loadTimeZone(prefsLongitude!, prefsLatitude!);

      if(prefsZone != null){
        await _loadPrayerTime(prefsZone);

        setState(() {
          zone = prefsZone;
          long = prefsLongitude!;
          lat = prefsLatitude!;
        });
      }
    }

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
        _getLocation();
      }
    }
    else{
      serviceStatus = false;
    }
  }

  Future<void> _getLocation() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      long = position.longitude.toString();
      lat = position.latitude.toString();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('prefsLongitude', long);
    await prefs.setString('prefsLatitude', lat);
    
    _loadTimeZone(long, lat);

    prefsZone = prefs.getString('prefsZone');

    if(prefsZone != null){
      setState(() {
        zone = prefsZone;
      });

      _loadPrayerTime(prefsZone);
    }
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

      setState(() {
        stateZone;
      });

    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadPrayerTime(zone) async {
    try {
      var prayerTime = await fetchPrayerTime(zone);

      setState(() {
        hijri = prayerTime['hijri'];
        date = prayerTime['date'];
        day = prayerTime['day'];
        imsak = prayerTime['imsak'].substring(0, 5);
        fajr = prayerTime['fajr'].substring(0, 5);
        syuruk = prayerTime['syuruk'].substring(0, 5);
        dhuhr = prayerTime['dhuhr'].substring(0, 5);
        asr = prayerTime['asr'].substring(0, 5);
        maghrib = prayerTime['maghrib'].substring(0, 5);
        isha = prayerTime['isha'].substring(0, 5);
      });

    } catch (e) {
      // Handle error
      print(e);
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              if (zone == null && (serviceStatus == false || requestPermission == false)) ... [
                const StatesZonesDropdownWidget(),

                 Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      prefsZone = prefs.getString('prefsZone');

                      if(prefsZone != null){
                        _loadPrayerTime(prefsZone);

                        setState(() {
                          zone = prefsZone;
                        });
                      }
                      else{
                        showDialog(
                          context: context,
                          builder: (context) => _buildConfirmationDialog(context),
                        ); 
                      }
                    },
                    child: const Text('Pilih'),
                  ),
                ),
              ]
              else if(zone != null && date.isNotEmpty) ... [
                PrayerTime(hijri: hijri, date: date, day: day,
                  imsak: imsak,
                  fajr: fajr,
                  syuruk: syuruk,
                  dhuhr: dhuhr,
                  asr: asr,
                  maghrib: maghrib,
                  isha: isha,
                ),
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
