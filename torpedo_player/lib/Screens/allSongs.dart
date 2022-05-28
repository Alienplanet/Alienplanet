import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:torpedo_player/Screens/player.dart';

import '../ResponsiveConstraints.dart';
import '../main.dart';
import 'frontScreen.dart';

class AllSongs extends StatefulWidget {
  const AllSongs() : super();

  @override
  _AllSongsState createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  printSongs() async {
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    List<SongInfo> songs = await audioQuery.getSongs();
    setState(() {
      allSongsList = songs;
    });
  }

  @override
  void initState() {
    super.initState();
    printSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body:
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: allSongsList.length,
                    itemBuilder: (context, index) => Container(
                      height: Responsive.height(8, context),
                      child: ListTile(
                          leading: Container(
                            height: 50,
                            width: 50,
                            child: Neumorphic(
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  border: NeumorphicBorder(isEnabled: true, color: textColor),
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.all(Radius.circular(5))),
                                  color: Colors.transparent,
                                  depth: 4,
                                  intensity: 0.5,
                                ),
                                child: allSongsList[index].albumArtwork == null?
                                Icon(
                                  Icons.music_note, size: 40, color: textColor,
                                ):
                                Image(
                                  fit: BoxFit.fitHeight,
                                  image: FileImage(File(allSongsList[index].albumArtwork)),
                                )
                            ),
                          ),
                          title: NeumorphicText(
                            allSongsList[index].title.length < 30
                                ? allSongsList[index].title
                                : allSongsList[index].title.substring(0, 29) + '...',
                            textAlign: TextAlign.left,
                            style: NeumorphicStyle(color: textColor),
                            textStyle: NeumorphicTextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: Responsive.height(2.0, context),
                            ),
                          ),
                          subtitle: NeumorphicText(
                            allSongsList[index].artist.length < 25
                                ? allSongsList[index].artist
                                : allSongsList[index].artist.substring(0, 25) + '...',
                            textAlign: TextAlign.left,
                            style: NeumorphicStyle(color: textColor),
                            textStyle: NeumorphicTextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: Responsive.height(2.0, context),
                            ),
                          ),
                          trailing: NeumorphicButton(
                            onPressed: () {
                              print("onClick");
                            },
                            style: NeumorphicStyle(
                              intensity: 5,
                              depth: 5,
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.circle(),
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.more_vert,
                              color: Color(primaryColor),
                              size: Responsive.width(4, context),
                            ),
                          ),

                          onTap: () {
                            playingSongIndex = index;
                            playingSongList = [...allSongsList];

                            prefs.setString('playingList', 'allSongs');
                            // prefs.setStringList('playingSongList', playingSongList);
                            prefs.setInt('playingSongIndex', index);
                            Navigator.push(context, _createRoute())
                                .then((_) {
                              print("brought back");
                              setState(() {



                              });
                            });
                          }),
                    ),
                  ),
                ),
                GestureDetector(
                  // onTap: (){
                  //   Navigator.push(context,
                  //       MaterialPageRoute(builder: (context) => Player()));
                  //
                  // },
                  child: Container(
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                        colors: [
                          gradientStartColor,
                          gradientEndColor]
                      )
                    ),
                    width: Responsive.width(100, context),
                    height: Responsive.height(9, context),
                    child: Padding(
                      padding: EdgeInsets.all(Responsive.height(1.5, context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: Responsive.height(6, context),
                                    width: Responsive.height(6, context),
                                    child: Image(
                                      image:
                                      playingSongList == null
                                        ? AssetImage('assets/sample_cover.jpg')
                                        : playingSongList[playingSongIndex].albumArtwork == null
                                        ? AssetImage('assets/sample_cover.jpg')
                                        : FileImage(
                                          File(playingSongList[playingSongIndex]
                                              .albumArtwork
                                          ),
                                      ) as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                              SizedBox(width: Responsive.height(2, context),),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  NeumorphicText(
                                    playingSongList==null
                                        ?'No Song Found'
                                        :playingSongList[playingSongIndex].title.length<25
                                        ?playingSongList[playingSongIndex].title
                                        :playingSongList[playingSongIndex].title.substring(0, 25) + '...',
                                    textAlign: TextAlign.left,
                                    style: NeumorphicStyle(color: textColor),
                                    textStyle: NeumorphicTextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: Responsive.height(2.0, context),
                                    ),
                                  ),
                                  NeumorphicText(
                                    playingSongList==null
                                        ?'No Artist Found'
                                        :playingSongList[playingSongIndex].artist.length<25
                                        ?playingSongList[playingSongIndex].artist
                                        :playingSongList[playingSongIndex].artist.substring(0, 25) + '...',
                                    textAlign: TextAlign.left,
                                    style: NeumorphicStyle(color: textColor),
                                    textStyle: NeumorphicTextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: Responsive.height(2.0, context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              NeumorphicButton(
                                onPressed: () {
                                  if (!playing) {
                                    playPressed();
                                  } else {
                                    setState(() {
                                      MediaNotification.showNotification(
                                          title: playingSongList[playingSongIndex].title,
                                          author: playingSongList[playingSongIndex].artist,
                                          isPlaying: false);
                                      setState(() => status = 'pause');
                                      player.pause();
                                      playIcon = Icons.play_arrow_rounded;
                                      playing = false;
                                    });
                                  }
                                },
                                style: NeumorphicStyle(
                                  intensity: 5,
                                  depth: 5,
                                  shape: NeumorphicShape.convex,
                                  boxShape: NeumorphicBoxShape.circle(),
                                  color: Color(primaryColor),
                                ),
                                child: Icon(
                                  playIcon,
                                  color: Colors.white,
                                  size: Responsive.width(6.0, context),
                                ),
                              ),
                              NeumorphicButton(
                                onPressed: () {
                                    playingSongIndex += 1;
                                    playPressed();
                                  },
                                style: NeumorphicStyle(
                                  intensity: 5,
                                  depth: 5,
                                  shape: NeumorphicShape.convex,
                                  boxShape: NeumorphicBoxShape.circle(),
                                  color: Color(primaryColor),
                                ),
                                child: Icon(
                                  Icons.fast_forward,
                                  color: Colors.white,
                                  size: Responsive.width(6.0, context),
                                ),
                              )
                              //IconButton(onPressed: (){}, icon: Icon(Icons.skip_next, color: Colors.white,)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        // )
    );
  }
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Player(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void playPressed() {
    setState(() {
      MediaNotification.showNotification(
          title: playingSongList[playingSongIndex].title,
          author: playingSongList[playingSongIndex].artist,
          isPlaying: true);
      setState(() => status = 'play');
      player.play(playingSongList[playingSongIndex].filePath, isLocal: true);
      playIcon = Icons.pause_rounded;
      playing = true;
    });
  }
}
