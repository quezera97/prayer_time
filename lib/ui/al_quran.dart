import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../api/al_quran.dart';
import '../components/loading_indicator.dart';
import '../enums/surah.dart';

class AlQuran extends StatefulWidget {
  const AlQuran({super.key});

  @override
  State<AlQuran> createState() => _AlQuranState();
}

class _AlQuranState extends State<AlQuran> {

  List<dynamic> randomSurah = [];
  String bismillah = "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ";
  String nameOfSurahArabic = '';
  String nameOfSurahEng = '';
  bool finishLoadAyahs = false;

  @override
  void initState() {
    _getRandomSurah(); 

    super.initState();
  }

  Future<void> _getRandomSurah() async {
    var apiRandomSurah = await fetchRandomSurah();

    if(apiRandomSurah.isNotEmpty || apiRandomSurah != []){
      nameOfSurahArabic = apiRandomSurah['name'];
      nameOfSurahEng = apiRandomSurah['englishName'];
      randomSurah = apiRandomSurah['ayahs'];

      setState(() {
        finishLoadAyahs = true;
      });
    }
  }

  Future<void> _getSelectedSurah(String surah) async {
    var apiSelectedSurah = await fetchSelectedSurah(surah);

    if(apiSelectedSurah.isNotEmpty || apiSelectedSurah != []){
      nameOfSurahArabic = apiSelectedSurah['name'];
      nameOfSurahEng = apiSelectedSurah['englishName'];
      randomSurah = apiSelectedSurah['ayahs'];

      setState(() {
        finishLoadAyahs = true;
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
        title: finishLoadAyahs == true 
        ? Text('$nameOfSurahArabic ($nameOfSurahEng)') 
        : const Text(''),
        backgroundColor: const Color(0xff764abc),
      ),
      body: Column(        
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                    showSelectedItems: true,
                ),
                items: surahOptions
                  .map((item) => '${item['surah']!}. ${item['option']!}')
                  .toList(),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Choose a Surah",
                    ),
                ),
                onChanged: (value) async {
                  _getSelectedSurah(value.toString());

                  setState(() {
                    finishLoadAyahs = false;
                  });
                },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.5),
            child: SizedBox(
              height: 45,
              child: Text(
                bismillah,
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          if(finishLoadAyahs == false) ... [
            loadingGifIndicator( gif: 'assets/img/loading.gif', message: 'Loading data5...'),
          ]
          else ... [
            Expanded(
              child: ListView.builder(
                itemCount: randomSurah.length,
                itemBuilder: (BuildContext context, int index) {

                  String textSurah = randomSurah[index]['text'];
                  textSurah = textSurah.replaceFirst(bismillah, "");

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ListTile(
                      title: Text(
                        textSurah,
                        style: const TextStyle(
                          fontSize: 17.5,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  );
                },
              ),
            ),
          ]
        ],
      ),
    );
  }
}