import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/dashboard.dart';
import 'ui/splash_screen.dart';
  
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // await Alarm.init(showDebugLogs: true);

  runApp(const MyApp());
} 

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void initState() {
    super.initState();
  }

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
        return null;
      },
      routes: {
        '/': (context) => const SplashScreen(),
      },
    );
  }
}
