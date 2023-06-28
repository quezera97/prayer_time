import 'package:flutter/material.dart';

import '../api/today_prayer_time.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String hijri = '';
  String date = '';
  String day = '';

  void initState() {
    super.initState();
    _loadApi();
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
          // Important: Remove any padding from the ListView.
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
