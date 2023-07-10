import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'ui/dashboard.dart';
import 'ui/splash_screen.dart';

const fetchBackground = "fetchBackground";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        getBackgroundTime();
        break;
    }
    return Future.value(true);
  });
}

void getBackgroundTime() async {

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await Workmanager().registerPeriodicTask(
    "1",
    fetchBackground,
    frequency: const Duration(seconds: 5),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
