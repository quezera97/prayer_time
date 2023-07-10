// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/state.dart';
import './options.dart';

class StatesZonesDropdownWidget extends StatefulWidget {

  const StatesZonesDropdownWidget({super.key});

  @override
  _StatesZonesDropdownWidgetState createState() => _StatesZonesDropdownWidgetState();
}

class _StatesZonesDropdownWidgetState extends State<StatesZonesDropdownWidget> {
  bool displayZone = false;
  String _selectedValueStates = '';
  String _selectedValueZones = '';
  
  List<Map<String, String>> statesOptions = [
    {'option': StateEnum.johor},
    {'option': StateEnum.kedah},
    {'option': StateEnum.kelantan},
    {'option': StateEnum.melaka},
    {'option': StateEnum.negeriSembilan},
    {'option': StateEnum.pahang},
    {'option': StateEnum.perak},
    {'option': StateEnum.perlis},
    {'option': StateEnum.pulauPinang},
    {'option': StateEnum.sabah},
    {'option': StateEnum.sarawak},
    {'option': StateEnum.selangor},
    {'option': StateEnum.terengganu},
    {'option': StateEnum.wilayahPersekutuan},
  ];
  
  List<Map<String, String>>? zoneOptions;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            DropdownButton(
              menuMaxHeight: 200,
              value: _selectedValueStates == '' ? null : _selectedValueStates,
              isExpanded: true,
              hint: const Text("Sila Pilih Negeri"),
              items: statesOptions
                  .map((item) => DropdownMenuItem(
                        value: item['option'],
                        child: Text(item['option']!),
                      ))
                  .toList(),
              onChanged: (value) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('prefsStateZone', value!);

                setState(() {
                  _selectedValueStates = value;

                  if (value == StateEnum.johor) {
                    zoneOptions = johorZoneOptions;
                  } 
                  else if (value == StateEnum.kedah) {
                    zoneOptions = kedahZoneOptions;
                  }
                  else if (value == StateEnum.kelantan) {
                    zoneOptions = kelantanZoneOptions;
                  }
                  else if (value == StateEnum.melaka) {
                    zoneOptions = melakaZoneOptions;
                  }
                  else if (value == StateEnum.negeriSembilan) {
                    zoneOptions = negeriSembilanZoneOptions;
                  }
                  else if (value == StateEnum.pahang) {
                    zoneOptions = pahangZoneOptions;
                  }
                  else if (value == StateEnum.perlis) {
                    zoneOptions = perlisZoneOptions;
                  }
                  else if (value == StateEnum.pulauPinang) {
                    zoneOptions = pulauPinangZoneOptions;
                  }
                  else if (value == StateEnum.perak) {
                    zoneOptions = perakZoneOptions;
                  }
                  else if (value == StateEnum.sabah) {
                    zoneOptions = sabahZoneOptions;
                  }
                  else if (value == StateEnum.sarawak) {
                    zoneOptions = sarawakZoneOptions;
                  }
                  else if (value == StateEnum.selangor) {
                    zoneOptions = selangorZoneOptions;
                  }
                  else if (value == StateEnum.terengganu) {
                    zoneOptions = terengganuZoneOptions;
                  }
                  else if (value == StateEnum.wilayahPersekutuan) {
                    zoneOptions = wilayahPersekutuanZoneOptions;
                  }

                  _selectedValueZones = '';

                  displayZone = true;

                });

                if(_selectedValueZones == ''){
                  await prefs.remove('prefsZone');
                }
              },
            ),

            if(displayZone) ... [
              DropdownButton(
                value: _selectedValueZones == '' ? null : _selectedValueZones,
                isExpanded: true,
                hint: const Text("Sila Pilih Daerah/Zon"),
                items: zoneOptions!
                  .map((item) => DropdownMenuItem(
                    value: item['value'],
                    child: Text(item['text']!),
                  ))
                  .toList(),
                onChanged: (value) async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('prefsZone', value!);

                  // prefs.setString('prefsLongitude', long);
                  // prefs.setString('prefsLatitude', lat);

                  setState(() {
                    _selectedValueZones = value;
                  });
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}
