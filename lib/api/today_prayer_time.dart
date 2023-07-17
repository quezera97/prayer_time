import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future fetchPrayerTime(zone) async {
  var url = Uri.parse('https://www.e-solat.gov.my/index.php?r=esolatApi/TakwimSolat&period=today&zone=$zone');

  try {
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var apiPrayerTime = jsonResponse['prayerTime'][0];

      return apiPrayerTime;
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}
