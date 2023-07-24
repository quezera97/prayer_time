// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/location_time_zone.dart';
import '../api/overseas_prayer_time.dart';
import '../components/loading_indicator.dart';
import '../components/popup_message.dart';
import '../enums/prayer_calculation_method.dart';
import '../enums/prayer_time.dart';
import '../qiblah/qiblah.dart';
import '../settings/settings.dart';
import 'al_quran.dart';
import 'asma_ul_husna.dart';
import 'dashboard.dart';
import 'muazzin.dart';

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

  String imsakName = PrayerTimeEnum.imsak;
  String fajrName = PrayerTimeEnum.fajr;
  String syurukName = PrayerTimeEnum.syuruk;
  String dhuhrName = PrayerTimeEnum.dhuhr;
  String asrName = PrayerTimeEnum.asr;
  String maghribName = PrayerTimeEnum.maghrib;
  String ishaName = PrayerTimeEnum.isha;

  bool finishLoad = false;

  String? muazzin;
  String prefsMuazzin = '';

  @override
  void initState() {
    _getInitPrefs();
    _getMuazzin();

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

      await _checkGps();
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
    await prefs.setBool('prefsInMalaysia', inMalaysia);

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

        await _loadPrayerTime(selectedValueMethod);
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

          imsak = prayerTime['Imsak'].substring(0, 5);
          fajr = prayerTime['Fajr'].substring(0, 5);
          syuruk = prayerTime['Sunrise'].substring(0, 5);
          dhuhr = prayerTime['Dhuhr'].substring(0, 5);
          asr = prayerTime['Asr'].substring(0, 5);
          maghrib = prayerTime['Maghrib'].substring(0, 5);
          isha = prayerTime['Isha'].substring(0, 5);

          finishLoad = true;
        });
      }
    }
  }

  Future<void> _getMuazzin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefsMuazzin = prefs.getString('prefsMuazzin') ?? 'RabehIbnDarahAlJazairi';

    String textMuazzin = prefsMuazzin.replaceAllMapped(RegExp(r'[A-Z][a-z]*'), (match) {
      return '${match.group(0)} ';
    });
    textMuazzin = textMuazzin.trim();

    setState(() {
      muazzin = textMuazzin;
    });
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
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xff764abc),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: Image.asset('assets/img/logo.png'),
                  ),
                  const Text(
                    'PRAYER TIME', 
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                    )
                  ),
                  // const Spacer(),
                  // const Text('Build Version: 1.0.0', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),            
            ListTile(
              leading: const Icon(
                Icons.language,
              ),
              title: const Text('Prayer Time'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
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
                Icons.abc,
              ),
              title: const Text('Asma Ul-Husna'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AsmaUlHusna()),
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
                Icons.collections_bookmark,
              ),
              title: const Text('Al-Quran'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlQuran()),
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

                      finishLoad = false;

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

              if(selectedValueMethod.isNotEmpty && finishLoad == true) ... [
                const Text('Method of Calculation:'),
                const SizedBox(height: 5),
                Text(
                  selectedOptionMethod, 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: SizedBox(
                                    height: 250,
                                    width: 250,
                                    child: Qiblah(),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Center(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(0, 5, 11, 0),
                                            child: Text(
                                              '$imsakName: $imsak',
                                              style: const TextStyle(
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                            child: Text(
                                              '$fajrName: $fajr',
                                              style: const TextStyle(
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(11, 5, 0, 0),
                                            child: Text(
                                              '$syurukName: $syuruk',
                                              style: const TextStyle(
                                                fontSize: 19,
                                              ),
                                            ),
                                          ), 
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(0, 5, 11, 0),
                                            child: Text(
                                              '$dhuhrName: $dhuhr',
                                              style: const TextStyle(
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                            child: Text(
                                              '$asrName: $asr',
                                              style: const TextStyle(
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(11, 5, 0, 0),
                                            child: Text(
                                              '$maghribName: $maghrib',
                                              style: const TextStyle(
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        child: Text(
                                          '$ishaName: $isha',
                                          style: const TextStyle(
                                            fontSize: 19,
                                          ),
                                        ),
                                      ),                                      
                                    ],
                                  )
                                )
                              ],
                            ),
                          ),
                          // Expanded(
                          //   child: 
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text( 
                        muazzin ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                          fontSize: 16.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ]
              else ... [
                loadingGifIndicator( gif: 'assets/img/loading.gif', message: 'Loading data...'),
              ]
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SizedBox(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.black54,
                    ),
                    Expanded( // or Flexible
                      child: Text(
                        stateZone ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: null,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}