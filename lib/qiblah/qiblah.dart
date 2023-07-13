import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

import '../components/loading_indicator.dart';
import 'qiblah_compass.dart';
import 'qiblah_maps.dart';

class Qiblah extends StatefulWidget {
  const Qiblah({super.key});

  @override
  State<Qiblah> createState() => _QiblahState();
}

class _QiblahState extends State<Qiblah> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _deviceSupport,
      builder: (_, AsyncSnapshot<bool?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return loadingGifIndicator( gif: 'assets/img/loading.gif', message: 'Loading...');
        }
          
        if (snapshot.hasError){
          return Center(
            child: Text("Error: ${snapshot.error.toString()}"),
          );
        }

        if (snapshot.data!){
          return const QiblahCompass();
        } else {
          return loadingGifIndicator( gif: 'assets/img/loading.gif', message: 'Loading data...');
        }
      },
    );
  }
}