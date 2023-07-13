import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future<dynamic> fetchAsmaUlHusna() async {

  var url = Uri.parse('http://api.aladhan.com/v1/asmaAlHusna');
  var responseAsmaUlHusna = await http.get(url);

  if (responseAsmaUlHusna.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(responseAsmaUlHusna.body);

    var asmaUlHusna = jsonResponse['data'];

    return asmaUlHusna;
  } else {
    throw Exception('Failed to fetch name');
  }
}