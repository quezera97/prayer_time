import 'dart:math';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future fetchRandomSurah() async {

  Random random = Random();
  int randomNumber = random.nextInt(114) + 1;

  var url = Uri.parse("https://api.alquran.cloud/v1/surah/$randomNumber");

  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var apiRandomSurah = jsonResponse['data'];

      return apiRandomSurah;
    } else {
      return [];
    }
  } catch (e) {
    return [];
  } 
}

Future fetchSelectedSurah(surah) async {

  var url = Uri.parse("https://api.alquran.cloud/v1/surah/$surah");

  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var apiSelectedSurah = jsonResponse['data'];

      return apiSelectedSurah;
    } else {
      return [];
    }
  } catch (e) {
    return [];
  } 
}
