import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future<Map<String, dynamic>> fetchTimeZone(String long, String lat) async {
  // String apiKey = 'aeded12e85174a288c9dcd28bd81d2fe';

  // var url = Uri.parse(
  //     'https://api.geoapify.com/v1/geocode/reverse?lat$lat&lon=$long&format=json&apiKey=$apiKey');

  var url = Uri.parse(
      'https://timeapi.io/api/Time/current/coordinate?latitude=$lat&longitude=$long');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    // var apiPrayerTime = jsonResponse['prayerTime'][0];

    return jsonResponse;
  } else {
    throw Exception('Failed to fetch time zone');
  }
}
