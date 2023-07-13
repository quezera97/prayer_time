// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/leading_icon_text.dart';
import '../enums/muazzin.dart';

class Muazzin extends StatefulWidget {
  const Muazzin({super.key});

  @override
  State<Muazzin> createState() => _MuazzinState();
}
class _MuazzinState extends State<Muazzin> {

  List<AudioPlayer> audioPlayers = [];

  @override
  void dispose() {
    for (var audioPlayer in audioPlayers) {
      audioPlayer.stop();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Pilihan Muazzin',
        ),
        backgroundColor: const Color(0xff764abc),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            for (var audioPlayer in audioPlayers) {
              audioPlayer.stop();
            }

            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: MuazzinEnum.values.length,
        itemBuilder: (context, index) {
          final enumValue = MuazzinEnum.values[index];
          String muazzin = enumValue.toString();

          // Make TextCamelCase become Text Camel Case
          String textMuazzin = muazzin.replaceAllMapped(RegExp(r'[A-Z][a-z]*'), (match) {
            return '${match.group(0)} ';
          });
          textMuazzin = textMuazzin.trim();

          return ListTile(
            title: Text(textMuazzin),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: const LeadIconText(icon: Icons.check, text: 'Set'),
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();

                          await prefs.setString('prefsMuazzin', muazzin);
                        },
                      ),
                    ];
                  },
                ),
                PlayAudio(muazzin: muazzin, audioPlayers: audioPlayers),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PlayAudio extends StatefulWidget {
  final String muazzin;
  final List<AudioPlayer> audioPlayers;

  const PlayAudio({Key? key, required this.muazzin, required this.audioPlayers})
      : super(key: key);

  @override
  State<PlayAudio> createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isAudioPlaying = false;

  @override
  Widget build(BuildContext context) {
    String muazzin = widget.muazzin;
    String audioAsset = "assets/audio/$muazzin.mp3";

    return InkWell(
      onTap: () {
        if (isAudioPlaying) {
          audioPlayer.stop();
          setState(() {
            isAudioPlaying = false;
          });
        }
        else {
          widget.audioPlayers.add(audioPlayer);

          if(widget.audioPlayers.length > 1){
            for (var audioPlayer in widget.audioPlayers) {
              audioPlayer.stop();
            }
          }

          setState(() {
            isAudioPlaying = true;
          });      

          audioPlayer.setAsset(audioAsset);
          audioPlayer.play();

          audioPlayer.playerStateStream.where((state) => state.processingState == ProcessingState.completed).first.then((_) {
            setState(() {
              isAudioPlaying = false;
            });
          });
        }
      },
      child: const Icon(Icons.play_circle_outline),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}