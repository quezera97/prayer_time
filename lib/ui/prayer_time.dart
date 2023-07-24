// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:prayer_time/api/today_prayer_time.dart';
import 'package:prayer_time/components/countdown_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/date_calc_prayer_time.dart';
import '../components/loading_indicator.dart';
import '../components/popup_message.dart';
import '../enums/prayer_time.dart';
import '../qiblah/qiblah.dart';

class PrayerTime extends StatefulWidget {  
  PrayerTime({super.key, required double height});

  double? height;

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

  String imsakName = PrayerTimeEnum.imsak;
  String fajrName = PrayerTimeEnum.fajr;
  String syurukName = PrayerTimeEnum.syuruk;
  String dhuhrName = PrayerTimeEnum.dhuhr;
  String asrName = PrayerTimeEnum.asr;
  String maghribName = PrayerTimeEnum.maghrib;
  String ishaName = PrayerTimeEnum.isha;
  
  String prefsZone = '';

  String? muazzin;
  String prefsMuazzin = '';

  @override
  void initState() {
    _checkZone();
    _getMuazzin();

    super.initState();
  }

  Future<void> _checkZone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefsZone = prefs.getString('prefsZone')!;

    if(prefsZone.isNotEmpty){
      _loadPrayerTime(prefsZone);
    }

  }

  Future<void> _loadPrayerTime(zone) async {    
    try {
      var prayerTime = await fetchPrayerTime(zone);

      if(prayerTime != []){
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

        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('prefsDate', date);
        await prefs.setString('prefsImsak', imsak);
        await prefs.setString('prefsFajr', fajr);
        await prefs.setString('prefsSyuruk', syuruk);
        await prefs.setString('prefsDhuhr', dhuhr);
        await prefs.setString('prefsAsr', asr);
        await prefs.setString('prefsMaghrib', maghrib);
        await prefs.setString('prefsIsha', isha);
      }
    } catch (e) {
      warningPopUp(context, e.toString());
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
            height: widget.height,
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
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
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
            height: MediaQuery.of(context).size.height / 1.5,
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
                            child: Text('Next Prayer', 
                              style: TextStyle(
                                fontSize: 25,
                                letterSpacing: 1.3,
                              )
                            )
                          ),

                          Center(child: CountdownClock(seconds: diffInSeconds)),

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
                                      color: numberOfItems == 7 ? const Color(0xff764abc) : Colors.transparent,
                                      child: Text(
                                        '$imsakName: $imsak',
                                        style: TextStyle(
                                          color: numberOfItems == 7 ? Colors.white : Colors.black,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                      color: numberOfItems == 1 ? const Color(0xff764abc) : Colors.transparent,
                                      child: Text(
                                        '$fajrName: $fajr',
                                        style: TextStyle(
                                          color: numberOfItems == 1 ? Colors.white : Colors.black,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(11, 5, 0, 0),
                                      color: numberOfItems == 2 ? const Color(0xff764abc) : Colors.transparent,
                                      child: Text(
                                        '$syurukName: $syuruk',
                                        style: TextStyle(
                                          color: numberOfItems == 2 ? Colors.white : Colors.black,
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
                                      color: numberOfItems == 3 ? const Color(0xff764abc) : Colors.transparent,
                                      child: Text(
                                        '$dhuhrName: $dhuhr',
                                        style: TextStyle(
                                          color: numberOfItems == 3 ? Colors.white : Colors.black,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                      color: numberOfItems == 4 ? const Color(0xff764abc) : Colors.transparent,
                                      child: Text(
                                        '$asrName: $asr',
                                        style: TextStyle(
                                          color: numberOfItems == 4 ? Colors.white : Colors.black,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(11, 5, 0, 0),
                                      color: numberOfItems == 5 ? const Color(0xff764abc) : Colors.transparent,
                                      child: Text(
                                        '$maghribName: $maghrib',
                                        style: TextStyle(
                                          color: numberOfItems == 5 ? Colors.white : Colors.black,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  color: numberOfItems == 6 ? const Color(0xff764abc) : Colors.transparent,
                                  child: Text(
                                    '$ishaName: $isha',
                                    style: TextStyle(
                                      color: numberOfItems == 6 ? Colors.white : Colors.black,
                                      fontSize: 19,
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
          )
        ],
      );
    }
    else{
      return loadingGifIndicator( gif: 'assets/img/loading.gif', message: 'Loading data...');
    }
  }
}