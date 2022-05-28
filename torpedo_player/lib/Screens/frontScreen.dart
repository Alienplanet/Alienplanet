import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torpedo_player/Screens/playlists.dart';

import '../ResponsiveConstraints.dart';
import '../main.dart';
import 'SearchScreen.dart';
import 'albums.dart';
import 'allSongs.dart';
import 'artists.dart';

class FrontScreen extends StatefulWidget {
  final b;

  FrontScreen({this.b});

  @override
  _FrontScreenState createState() => _FrontScreenState();
}

const gradientStartColor = const Color(0xFFFFFFFF);
const gradientEndColor = const Color(0xFFFFFFFF);

SharedPreferences prefs = prefs;

class _FrontScreenState extends State<FrontScreen>
    with AutomaticKeepAliveClientMixin<FrontScreen>{

  @override
  void initState() {
    super.initState();
    printSongs();
    MediaNotification.setListener('pause', () {
      setState(() => status = 'pause');
      pausePressed();
    });

    MediaNotification.setListener('play', () {
      setState(() => status = 'play');
      playPressed();
    });

    MediaNotification.setListener('next', () {
      playingSongIndex += 1;
      playPressed();
    });

    MediaNotification.setListener('prev', () {
      playingSongIndex -= 1;
      playPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          DefaultTabController(
              length: 4,
              child: Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(100.0), // here the desired height
                    child: AppBar(
                      brightness: Brightness.dark,
                      backgroundColor: Colors.transparent,
                      flexibleSpace: Container(
                          decoration: new BoxDecoration(
                            //color: Colors.transparent
                              gradient: new LinearGradient(colors: [
                                gradientStartColor,
                                gradientEndColor
                              ])
                          )
                      ),
                      bottom: TabBar(
                        physics: NeverScrollableScrollPhysics(),
                        tabs: [
                          Tab(text: 'SONGS'),
                          Tab(text: 'PLAYLISTS'),
                          Tab(text: 'ARTISTS'),
                          Tab(text: 'ALBUMS'),
                        ],
                        labelColor: textColor,
                        labelStyle: TextStyle(
                            fontSize: Responsive.height(2, context),
                            fontWeight: FontWeight.w400),
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorColor: Color(primaryColor),
                      ),
                      title: Padding(
                        padding: EdgeInsets.only(
                            left: Responsive.height(1.5, context),
                            top: Responsive.height(2.0, context)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.,
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                NeumorphicText(
                                  'TORPEDO  ',
                                  style: NeumorphicStyle(color: Color(primaryColor)),
                                  textStyle: NeumorphicTextStyle(
                                      fontSize: Responsive.height(4, context),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Teko'
                                    // fontFamily: 'Copperplate'
                                  ),
                                ),
                                NeumorphicText(
                                  'PLAYER',
                                  style: NeumorphicStyle(color: textColor),
                                  textStyle: NeumorphicTextStyle(
                                    fontSize: Responsive.height(2, context),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchPage()));
                                    }, icon: Icon(Icons.search),
                                  color: Color(primaryColor),),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: TabBarView(
                    children: [AllSongs(), Playlists(), Artists(), Albums()],
                  ))),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  printSongs() async {
    prefs = await SharedPreferences.getInstance();
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    List<SongInfo> songs = await audioQuery.getSongs();
    print('here');
    setState(() {
      allSongsList = songs;
      playingSongList = [...allSongsList];
      playingSongIndex = (prefs.getInt('playingSongIndex') ?? 0);
      playingList = (prefs.getString('playingList')?? 'allSongs');
      shuffle = (prefs.getBool('shuffle')?? false);
      repeat = (prefs.getInt('repeat')?? 0);
      print('repeat: $repeat shuffle: $shuffle');
    });
  }

  playPressed(){
    setState(() {
      MediaNotification.showNotification(
          title: playingSongList[playingSongIndex].title,
          author: playingSongList[playingSongIndex].artist,
          isPlaying: true);
      setState(() => status = 'play');
      player.play(
          playingSongList[playingSongIndex].filePath,
          isLocal: true);
      playing = true;
      print('now playing');
    });
  }

  pausePressed(){
    setState(() {
      MediaNotification.showNotification(
          title: playingSongList[playingSongIndex].title,
          author: playingSongList[playingSongIndex].artist,
          isPlaying: false);
      setState(() => status = 'pause');
      player.pause();
      playing = false;
    });
  }
}
