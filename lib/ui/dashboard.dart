import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../api/today_prayer_time.dart';

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

  void initState() {
    _loadApi();
    checkGps();
    super.initState();
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus){
          permission = await Geolocator.checkPermission();
        
          if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.denied) {
                  print('Location permissions are denied');
              }else if(permission == LocationPermission.deniedForever){
                  print("'Location permissions are permanently denied");
              }else{
                  haspermission = true;
              }
          }else{
              haspermission = true;
          }

          if(haspermission){
              setState(() {
                //refresh the UI
              });

              getLocation();
          }
    }else{
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
        //refresh the UI
    });
  }

  getLocation() async {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
         //refresh UI
      });

      LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high, //accuracy of the location data
            distanceFilter: 100, //minimum distance (measured in meters) a 
                                 //device must move horizontally before an update event is generated;
      );

      StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
            locationSettings: locationSettings).listen((Position position) {
            print(position.longitude); //Output: 80.24599079
            print(position.latitude); //Output: 29.6593457

            long = position.longitude.toString();
            lat = position.latitude.toString();

            setState(() {
              //refresh UI on update
            });
      });
  }

  Future<void> _loadApi() async {
    try {
      var prayerTime = await fetchPrayerTime();

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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Navigation Drawer',
        ),
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
              leading: Icon(
                Icons.home,
              ),
              title: const Text('Page 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
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
      body: Center(
        child: Column(
          children: [
            Text(servicestatus? "GPS is Enabled": "GPS is disabled."),
                     Text(haspermission? "GPS is Enabled": "GPS is disabled."),
                     
                     Text("Longitude: $long", style:TextStyle(fontSize: 20)),
                     Text("Latitude: $lat", style: TextStyle(fontSize: 20),),
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
          ],
        ),
      ),
    );
  }
}
