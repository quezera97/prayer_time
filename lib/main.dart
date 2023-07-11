import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:just_audio/just_audio.dart';

import 'components/date_calc_prayer_time.dart';
import 'ui/dashboard.dart';
import 'ui/splash_screen.dart';

String prefsDate = '';
String prefsImsak = '';
String prefsFajr = '';
String prefsSyuruk = '';
String prefsDhuhr = '';
String prefsAsr = '';
String prefsMaghrib = '';
String prefsIsha = '';

final AudioPlayer _audioPlayer = AudioPlayer();

Future<void> getBackgroundTime() async {
  bool checkDateNowWithPrayer = false;

  SharedPreferences prefs = await SharedPreferences.getInstance();

  prefsDate = prefs.getString('prefsDate') ?? '';
  prefsFajr = prefs.getString('prefsFajr') ?? '';
  prefsDhuhr = prefs.getString('prefsDhuhr') ?? '';
  prefsAsr = prefs.getString('prefsAsr') ?? '';
  prefsMaghrib = prefs.getString('prefsMaghrib') ?? '';
  prefsIsha = prefs.getString('prefsIsha') ?? '';

  if(prefsDate.isNotEmpty){
    var fajr = "$prefsFajr:00";
    var dhuhr = "$prefsDhuhr:00";
    var asr = "$prefsAsr:00";
    var maghrib = "$prefsMaghrib:00";
    var isha = "$prefsIsha:00";
    
    List<String> prayerTime = [ fajr, dhuhr, asr, maghrib, isha ];

    checkDateNowWithPrayer = dateParsingMain(prayerTime, prefsDate);      
  }
  else{
    checkDateNowWithPrayer = false;
  }

  if(checkDateNowWithPrayer == true){      
    _playAudioAndNavigate();
  }
}

bool isAudioPlaying = false;

Future<void> _playAudioAndNavigate() async {
  if (!isAudioPlaying) {
    String audioAsset = "assets/audio/RabehIbnDarahAlJazairi.mp3";
    await _audioPlayer.setAsset(audioAsset);
    await _audioPlayer.play();

    _audioPlayer.playerStateStream.where((state) => state.processingState == ProcessingState.completed).first.then((_) {
      isAudioPlaying = false;
    });

    isAudioPlaying = true;
  }
}
  
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeService();

  FlutterBackgroundService().invoke("setAsBackground");

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    await getBackgroundTime();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prayer Time',
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/dashboard':
            return MaterialPageRoute(builder: (context) => const Dashboard());
        }
      },
      routes: {
        '/': (context) => const SplashScreen(),
      },
    );
  }
}
