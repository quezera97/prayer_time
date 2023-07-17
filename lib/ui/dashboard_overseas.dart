import 'package:flutter/material.dart';

class DashboardOverseas extends StatefulWidget {
  const DashboardOverseas({super.key});

  @override
  State<DashboardOverseas> createState() => _DashboardOverseasState();
}

class _DashboardOverseasState extends State<DashboardOverseas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Prayer Time (Overseas)',
        ),
        backgroundColor: const Color(0xff764abc),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
      ),
      body: SizedBox(),
    );
  }
}