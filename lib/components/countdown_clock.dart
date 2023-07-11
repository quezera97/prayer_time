// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

class CountdownClock extends StatefulWidget {
  final int seconds;
  const CountdownClock({super.key, required this.seconds});

  @override
  _CountdownClockState createState() => _CountdownClockState();
}

class _CountdownClockState extends State<CountdownClock> {
  late Timer _timer;
  int _secondsRemaining = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.seconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          _playAudioAndNavigate();
        }
      });
    });
  }
  
  Future<void> _playAudioAndNavigate() async {

    String audioAsset = "assets/audio/RabehIbnDarahAlJazairi.mp3";
    await _audioPlayer.setAsset(audioAsset);
    await _audioPlayer.play();

    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/dashboard');
    
    _audioPlayer.playerStateStream.firstWhere((state) => state.processingState == ProcessingState.completed).then((_) {
      
    });
  }

  @override
  void dispose() {
    _timer.cancel();
     _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(seconds: _secondsRemaining);
    String formattedTime = DateFormat.Hms().format(DateTime(0, 0, 0).add(duration));
    return Text(
      formattedTime,
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
