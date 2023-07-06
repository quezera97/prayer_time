import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/components/countdown_clock.dart';

class PrayerTime extends StatefulWidget {
  const PrayerTime({super.key, 
    required this.hijri, required this.date, required this.day, 
    required this.imsak, 
    required this.fajr, 
    required this.syuruk, 
    required this.dhuhr, 
    required this.asr, 
    required this.maghrib, 
    required this.isha,
  });

  final String hijri; final String date; final String day;
  final String imsak;
  final String fajr;
  final String syuruk;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  @override
  State<PrayerTime> createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  @override
  Widget build(BuildContext context) {    

    List<String> prayerTime = [ widget.imsak, widget.fajr, widget.syuruk, widget.dhuhr, widget.asr, widget.maghrib, widget.isha ];

    List<String> nameOfPrayer = [ 'imsak', 'fajr', 'syuruk', 'dhuhr', 'asr', 'maghrib', 'isha' ];

    int numberOfItems  = dateParsing(prayerTime, widget.date, nameOfPrayer);

    int diffInSeconds = 0;

    if(numberOfItems == 7){
      setState(() {
        diffInSeconds = countdownSeconds(widget.imsak);
      });
    }
    else if(numberOfItems == 1){
      setState(() {
        diffInSeconds = countdownSeconds(widget.fajr);
      });
    }
    else if(numberOfItems == 2){
      setState(() {
        diffInSeconds = countdownSeconds(widget.syuruk);
      });
    }
    else if(numberOfItems == 3){
      setState(() {
        diffInSeconds = countdownSeconds(widget.dhuhr);
      });
    }
    else if(numberOfItems == 4){
      setState(() {
        diffInSeconds = countdownSeconds(widget.asr);
      });
    }
    else if(numberOfItems == 5){
      setState(() {
        diffInSeconds = countdownSeconds(widget.maghrib);
      });
    }
    else if(numberOfItems == 6){
      setState(() {
        diffInSeconds = countdownSeconds(widget.isha);
      });
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
                  Text('Hijri: ${widget.hijri}'),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Day: ${widget.day}'),
                      const SizedBox(width: 30),
                      Text('Date: ${widget.date}')
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
                            'Imsak: ${widget.imsak}',
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
                            'Fajr: ${widget.fajr}',
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
                            'Syuruk: ${widget.syuruk}',
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
                            'Dhuhr: ${widget.dhuhr}',
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
                            'Asr: ${widget.asr}',
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
                            'Maghrib: ${widget.maghrib}',
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
                            'Isha: ${widget.isha}',
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