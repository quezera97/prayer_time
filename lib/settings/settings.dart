import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../components/alert_pop_up.dart';
import 'join_text_about_us.dart';
import 'join_text_policy.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final String packageName = 'test';

  Future<void> _feedbackApp() async {
    Uri url = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName&showAllReviews=true');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _shareApp() async {
    String url =
        'https://play.google.com/store/apps/details?id=$packageName&showAllReviews=true';

    if (await canLaunchUrl(Uri.parse(url))) {
      await Share.share(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Waktu Solat',
          ),
          backgroundColor: const Color(0xff764abc),
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Card(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: ListTile(
                          title: const Text(
                            'Send Feedback',
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left,
                          ),
                          onTap: _feedbackApp,
                        ),
                      ),
                      const Divider(
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: ListTile(
                          title: const Text(
                            'Share & Recommend',
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left,
                          ),
                          onTap: _shareApp,
                        ),
                      ),                
                    ]
                  ),
                ),
                
                Card(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: ListTile(
                          title: const Text(
                            'About Us',
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertPopUp(
                                  titleAlert: 'QueZ Apps', 
                                  contentAlert: joinedTextAboutUs(),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const Divider(
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: ListTile(
                          title: const Text(
                            'Privacy Policy',
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertPopUp(
                                  titleAlert: 'Privacy Policy', 
                                  contentAlert: joinedTextPrivacyPolicy(),
                                );
                              },
                            );
                          },
                        ),
                      ),                        
                    ]
                  )
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Center(
                  child: Text(
                    'Build Version: 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 70, 70, 70),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
