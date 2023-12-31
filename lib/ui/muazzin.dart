
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/leading_icon_text.dart';
import '../enums/muazzin.dart';
import 'dashboard.dart';
import 'dashboard_overseas.dart';
class Muazzin extends StatefulWidget {
  const Muazzin({super.key});

  @override
  State<Muazzin> createState() => _MuazzinState();
}

class _MuazzinState extends State<Muazzin> {
  @override
  void initState() {
    _getMuazzin(); 

    super.initState();
  }

  String muazzin = '';
  String prefsMuazzin = '';

  Future<void> _getMuazzin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefsMuazzin = prefs.getString('prefsMuazzin') ?? 'RabehIbnDarahAlJazairi';

    String textMuazzin = changeNameCamelCase(prefsMuazzin);

    setState(() {
      muazzin = textMuazzin;
    });
  }

  List<AudioPlayer> audioPlayers = [];

  String changeNameCamelCase(muazzinEnum){
    // Make TextCamelCase become Text Camel Case
    String textMuazzin = muazzinEnum.replaceAllMapped(RegExp(r'[A-Z][a-z]*'), (match) {
      return '${match.group(0)} ';
    });

    textMuazzin = textMuazzin.trim();

    return textMuazzin;
  }

  @override
  void dispose() {
    for (var audioPlayer in audioPlayers) {
      audioPlayer.stop();
    }
    super.dispose();
  }

  bool? prefsInMalaysia;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Muazzin'),
        backgroundColor: const Color(0xff764abc),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            for (var audioPlayer in audioPlayers) {
              audioPlayer.stop();
            }

            SharedPreferences prefs = await SharedPreferences.getInstance();

            prefsInMalaysia = prefs.getBool('prefsInMalaysia') ?? true;

            if(prefsInMalaysia!){              
              await Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Dashboard()));
            }
            else{
              await Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const DashboardOverseas()));
            }
          },
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text(
              'Selected Muazzin', 
              textAlign: TextAlign.center
            ),
            subtitle: Text(
              muazzin,
              textAlign: TextAlign.center
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: MuazzinEnum.values.length,
              itemBuilder: (context, index) {
                final enumValue = MuazzinEnum.values[index];
                String muazzinEnum = enumValue.toString();

                String textMuazzin = changeNameCamelCase(muazzinEnum);

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

                                await prefs.setString('prefsMuazzin', muazzinEnum);

                                String textMuazzin = changeNameCamelCase(muazzinEnum);

                                setState(() {
                                  muazzin = textMuazzin;
                                });
                              },
                            ),
                          ];
                        },
                      ),
                      PlayAudio(muazzin: muazzinEnum, audioPlayers: audioPlayers),
                    ],
                  ),
                );
              },
            )
          ),
        ],
      ),
    );
  }
}

class PlayAudio extends StatefulWidget {
  final String muazzin;
  final List<AudioPlayer> audioPlayers;

  const PlayAudio({super.key, required this.muazzin, required this.audioPlayers});


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
      child: isAudioPlaying == false ? const Icon(Icons.play_circle_outline) : const Icon(Icons.stop),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}