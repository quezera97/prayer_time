import 'package:flutter/material.dart';

import '../api/asma_ul_husna.dart';
import '../components/alert_pop_up.dart';
import '../components/loading_indicator.dart';

class AsmaUlHusna extends StatefulWidget {
  const AsmaUlHusna({super.key});

  @override
  State<AsmaUlHusna> createState() => _AsmaUlHusnaState();
}

class _AsmaUlHusnaState extends State<AsmaUlHusna> {
  String searchedValue = '';
  List<dynamic> listAsmaUlHusna = [];
  bool finishLoadAsmaUlHusna = false;

  @override
  void initState() {
    _getAsmaUlHusna(); 

    super.initState();
  }

  void _getAsmaUlHusna() async {
    var apiAsmaUlHusna = await fetchAsmaUlHusna();

    if(apiAsmaUlHusna.isNotEmpty || apiAsmaUlHusna != []){
      setState(() {
        finishLoadAsmaUlHusna = true;
        listAsmaUlHusna = apiAsmaUlHusna;
      });
    }

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Asma Ul-Hunsa',
        ),
        backgroundColor: const Color(0xff764abc),
      ),
      body: finishLoadAsmaUlHusna == false
        ? loadingGifIndicator( gif: 'assets/img/loading.gif', message: 'Loading data...')
        : GridView.count(
        padding: const EdgeInsets.all(10),
        crossAxisCount: 3,
        children: List.generate(listAsmaUlHusna.length, (index) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return  AlertPopUp(
                          titleAlert: listAsmaUlHusna[index]['name'], 
                          contentAlert: listAsmaUlHusna[index]['en']['meaning'],
                        );
                      },
                    ); 
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Text(
                          listAsmaUlHusna[index]['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          listAsmaUlHusna[index]['transliteration'],
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      )
    );
  }
}