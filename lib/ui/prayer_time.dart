import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/api/today_prayer_time.dart';
import 'package:prayer_time/components/countdown_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/loading_indicator.dart';

class PrayerTime extends StatefulWidget {
  const PrayerTime({super.key});

  @override
  State<PrayerTime> createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {

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
  
  String? stateZone;
  String prefsZone = '';

  @override
  void initState() {
    _checkZone();

    super.initState();
  }

  Future<void> _checkZone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefsZone = prefs.getString('prefsZone')!;

    if(prefsZone.isNotEmpty){
      _loadPrayerTime(prefsZone);
    }
    else{
      setState(() {
        stateZone = null;
      });
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

  @override
  Widget build(BuildContext context) {    

    if(date.isNotEmpty){
      List<String> prayerTime = [ imsak, fajr, syuruk, dhuhr, asr, maghrib, isha ];
      List<String> nameOfPrayer = [ 'imsak', 'fajr', 'syuruk', 'dhuhr', 'asr', 'maghrib', 'isha' ];

      int numberOfItems  = dateParsing(prayerTime, date, nameOfPrayer);

      int diffInSeconds = 0;

      if(numberOfItems == 7){        
        diffInSeconds = countdownSeconds(imsak);
      }
      else if(numberOfItems == 1){        
        diffInSeconds = countdownSeconds(fajr);
      }
      else if(numberOfItems == 2){        
        diffInSeconds = countdownSeconds(syuruk);
      }
      else if(numberOfItems == 3){        
        diffInSeconds = countdownSeconds(dhuhr);
      }
      else if(numberOfItems == 4){        
        diffInSeconds = countdownSeconds(asr);
      }
      else if(numberOfItems == 5){        
        diffInSeconds = countdownSeconds(maghrib);
      }
      else if(numberOfItems == 6){        
        diffInSeconds = countdownSeconds(isha);
      }

      return Column(
        children: [
          SizedBox(
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
              )
            )
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
                          Center(child: CountdownClock(seconds: diffInSeconds)),

                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                            color: numberOfItems == 7 ? const Color(0xff764abc) : Colors.transparent,
                            child: Text(
                              'Imsak: $imsak',
                              style: TextStyle(
                                color: numberOfItems == 7 ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                            color: numberOfItems == 1 ? const Color(0xff764abc) : Colors.transparent,
                            child: Text(
                              'Fajr: $fajr',
                              style: TextStyle(
                                color: numberOfItems == 1 ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                            color: numberOfItems == 2 ? const Color(0xff764abc) : Colors.transparent,
                            child: Text(
                              'Syuruk: $syuruk',
                              style: TextStyle(
                                color: numberOfItems == 2 ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(                          
                            margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                            color: numberOfItems == 3 ? const Color(0xff764abc) : Colors.transparent,
                            child: Text(
                              'Dhuhr: $dhuhr',
                              style: TextStyle(
                                color: numberOfItems == 3 ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                            color: numberOfItems == 4 ? const Color(0xff764abc) : Colors.transparent,
                            child: Text(
                              'Asr: $asr',
                              style: TextStyle(
                                color: numberOfItems == 4 ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                            color: numberOfItems == 5 ? const Color(0xff764abc) : Colors.transparent,
                            child: Text(
                              'Maghrib: $maghrib',
                              style: TextStyle(
                                color: numberOfItems == 5 ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                            color: numberOfItems == 6 ? const Color(0xff764abc) : Colors.transparent,
                            child: Text(
                              'Isha: $isha',
                              style: TextStyle(
                                color: numberOfItems == 6 ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
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
          )
        ],
      );
    
    }
    else{
      return loadingGifIndicator( gif: 'assets/img/loading.gif', message: 'Loading data...');
    }
  }

  int dateParsing(List<String> prayerTimes, String date, List<String> nameOfPrayer) {
    TimeOfDay currentTime = TimeOfDay.now();
    DateTime parsedDate = DateFormat("dd-MMM-yyyy").parse(date);
    String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
    DateTime currentDateTime = DateTime.now();
    DateTime currentTimeWithDate = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      currentTime.hour,
      currentTime.minute,
    );

    List<String> prayersGreaterThanCurrentTime = [];

    for (int i = 0; i < prayerTimes.length; i++) {
      String prayerTime = prayerTimes[i];
      String prayerName = nameOfPrayer[i];

      String fullDateTime = "$formattedDate $prayerTime";

      DateTime comparedDateTime = DateTime.parse(fullDateTime);

      if (currentTimeWithDate.isAfter(comparedDateTime) || currentTimeWithDate == comparedDateTime) {
        prayersGreaterThanCurrentTime.add(prayerName);
      }
    }

    int numberOfItems = prayersGreaterThanCurrentTime.length;

    return numberOfItems;
  }

  int countdownSeconds(String date) {
    List<String> timeParts = date.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    
    TimeOfDay targetTime = TimeOfDay(hour: hour, minute: minute);
    
    DateTime now = DateTime.now();
    DateTime targetDateTime = DateTime(now.year, now.month, now.day, targetTime.hour, targetTime.minute);
    
    Duration difference = targetDateTime.difference(now);
    int differenceInSeconds = difference.inSeconds;
    
    return differenceInSeconds;
  }

}