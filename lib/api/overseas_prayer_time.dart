import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future fetchOverseasPrayerTime(String long, String lat, String method) async {
  final DateTime now = DateTime.now();
  final int currentYear = now.year;
  final int currentMonth = now.month;

  var url = Uri.parse('http://api.aladhan.com/v1/calendar/$currentYear/$currentMonth?latitude=$lat&longitude=$long&method=$method');

  try {
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var apiPrayerTime = jsonResponse['data'][0]['timings'];

      return apiPrayerTime;
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}
