import 'package:flutter/material.dart';

import 'ui/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Malaysia Slang',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: HomePage(),
      routes: {
        '/': (context) => const SplashScreen(),
      },
    );
  }
}
