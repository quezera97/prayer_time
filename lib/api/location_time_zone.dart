import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future<dynamic> fetchTimeZone(String long, String lat) async {

  var url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$long');

  try {
    var responseLatLong = await http.get(url);

    if (responseLatLong.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(responseLatLong.body);
      var apiDisplayName = jsonResponse['display_name'];
      var apiState = jsonResponse['address']['state'];

      return apiDisplayName;
    } else {
      return '';
    }
  } catch (e) {
    return '';
  }
  
}