// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/location_time_zone.dart';
import '../api/overseas_prayer_time.dart';
import '../components/popup_message.dart';
import '../enums/prayer_calculation_method.dart';
import 'dashboard.dart';

class DashboardOverseas extends StatefulWidget {
  
  const DashboardOverseas({super.key});

  
  @override
  State<DashboardOverseas> createState() => _DashboardOverseasState();
}

class _DashboardOverseasState extends State<DashboardOverseas> {
  bool serviceStatus = false;
  bool requestPermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  String? prefsLongitude;
  String? prefsLatitude;

  String imsak = '';
  String fajr = '';
  String syuruk = '';
  String dhuhr = '';
  String asr = '';
  String maghrib = '';
  String isha = '';

  String selectedValueMethod = '';
  String selectedOptionMethod = '';

  String? stateZone;
  String? prefsStateZone;

  String prefsValueMethod = '';
  String prefsOptionMethod = '';

  List<Map<String, String>> calculationMethod = [
    {'value': '1', 'option': CalculationMethodEnum.karachi},
    {'value': '2', 'option': CalculationMethodEnum.northAmerica},
    {'value': '3', 'option': CalculationMethodEnum.muslimWorldLeague},
    {'value': '4', 'option': CalculationMethodEnum.makkah},
    {'value': '5', 'option': CalculationMethodEnum.egypt},
    {'value': '7', 'option': CalculationMethodEnum.tehran},
    {'value': '8', 'option': CalculationMethodEnum.gulf},
    {'value': '9', 'option': CalculationMethodEnum.kuwait},
    {'value': '10', 'option': CalculationMethodEnum.qatar},
    {'value': '11', 'option': CalculationMethodEnum.singapore},
    {'value': '12', 'option': CalculationMethodEnum.france},
    {'value': '13', 'option': CalculationMethodEnum.turkey},
    {'value': '14', 'option': CalculationMethodEnum.russia},
    {'value': '16', 'option': CalculationMethodEnum.dubai},
  ];

  @override
  void initState() {
    _getInitPrefs();

    super.initState();
  }

  Future<void> _getInitPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefsOptionMethod = prefs.getString('prefsOptionMethod') ?? '';
    prefsValueMethod = prefs.getString('prefsValueMethod') ?? '';
    
    if(prefsOptionMethod.isNotEmpty && prefsOptionMethod.isNotEmpty){
      setState(() {
        selectedValueMethod = prefsOptionMethod;
        selectedOptionMethod = prefsValueMethod;
      });

      await _loadPrayerTime(selectedValueMethod);
    }

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

        prefsStateZone = prefs.getString('prefsStateZone');
        prefsLongitude = prefs.getString('prefsLongitude');
        prefsLatitude = prefs.getString('prefsLatitude');

        setState(() {
          stateZone = prefsStateZone;

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
    
    bool inMalaysia = await _checkInMalaysia(long, lat);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('prefsLongitude', long);
    await prefs.setString('prefsLatitude', lat);

    if(!inMalaysia){
      await _loadTimeZone(long, lat);
    }
    else {
      successPopUpRedirect(context, 'You are in Malaysia', const Dashboard());
    } 
  }

  Future<bool> _checkInMalaysia(String long, String lat) async {
    final double latitude = double.parse(lat);
    final double longitude = double.parse(long);

    if (latitude < 1.0 || latitude > 7.5 || longitude < 100.0 || longitude > 119.0){
      return false;
    }

    return true;
  }

  Future<void> _loadTimeZone(String long, String lat) async {
    try {

      stateZone = await fetchTimeZone(long, lat);      

      if(stateZone!.isNotEmpty || stateZone != '' ){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('prefsStateZone', stateZone!);
        await prefs.setString('prefsLongitude', long);
        await prefs.setString('prefsLatitude', lat);
      }

      setState(() {
        stateZone;
      });

    } catch (e) {
      warningPopUp(context, e.toString());    
    }
  }

  Future<void> _loadPrayerTime(valueMethod) async {
    
    if(long.isNotEmpty && lat.isNotEmpty){
      stateZone = await fetchTimeZone(long, lat);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('prefsStateZone', stateZone!);

      var prayerTime = await fetchOverseasPrayerTime(long, lat, valueMethod);

      if(prayerTime != []){
        setState(() {
          stateZone;

          imsak = prayerTime['Imsak'].replaceAll(' (+08)', '');
          fajr = prayerTime['Fajr'].replaceAll(' (+08)', '');
          syuruk = prayerTime['Sunrise'].replaceAll(' (+08)', '');
          dhuhr = prayerTime['Dhuhr'].replaceAll(' (+08)', '');
          asr = prayerTime['Asr'].replaceAll(' (+08)', '');
          maghrib = prayerTime['Maghrib'].replaceAll(' (+08)', '');
          isha = prayerTime['Isha'].replaceAll(' (+08)', '');
        });
      }
    }
  } 

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Prayer Time (Overseas)',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: DropdownButton(
                  menuMaxHeight: 200,
                  isExpanded: true,
                  hint: const Text("Please Choose Prayer Calculation"),
                  items: calculationMethod
                    .map((item) => DropdownMenuItem(
                          value: item['value'],
                          child: Text(item['option']!),
                        ))
                    .toList(),
                  onChanged: (value) async {
                    setState(() {
                      selectedValueMethod = value!;
                      selectedOptionMethod = calculationMethod.firstWhere((item) => item['value'] == value)['option']!;

                      if(selectedValueMethod.isNotEmpty){
                        _loadPrayerTime(selectedValueMethod);
                      }
                    });

                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('prefsOptionMethod', selectedValueMethod);
                    await prefs.setString('prefsValueMethod', selectedOptionMethod);
                  }
                ),
              ),
              const SizedBox(height: 10),

              if(selectedValueMethod.isNotEmpty) ... [
                const Text('Method of Calculation:'),
                const SizedBox(height: 5),
                Text(selectedOptionMethod),
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