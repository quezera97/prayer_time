import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    if (currentTimeWithDate == comparedDateTime || currentTimeWithDate.isAfter(comparedDateTime)) {
      prayersGreaterThanCurrentTime.add(prayerName);
    }
  }

  int numberOfItems = prayersGreaterThanCurrentTime.length;

  return numberOfItems;
}

bool dateParsingMain(List<String> prayerTimes, String date) {
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
    DateTime.now().second,
  );

  for (int i = 0; i < prayerTimes.length; i++) {
    String prayerTime = prayerTimes[i];

    String fullDateTime = "$formattedDate $prayerTime";

    DateTime comparedDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(fullDateTime);

    if (currentTimeWithDate == comparedDateTime) {
      return true;
    }
  }

  return false;
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