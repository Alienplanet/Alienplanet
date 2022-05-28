import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:torpedo_player/Screens/player.dart';

import '../ResponsiveConstraints.dart';
import '../main.dart';
import 'frontScreen.dart';

class Playlists extends StatefulWidget {
  const Playlists() : super();

  @override
  _PlaylistsState createState() => _PlaylistsState();
}

const gradientStartColor = const Color(0xFF2F2F2F);
const gradientEndColor = const Color(0xFF1A1A1A);

class _PlaylistsState extends State<Playlists> {

  printSongs() async {
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    var Playlist = await audioQuery.getPlaylists();
    //List<SongInfo> songs = await audioQuery.getSongsFromPlaylist(playlist: playlist[0]);
    // SongInfo song;
    // /// adding songs into a specific playlist
    // PlaylistInfo createdPlaylist = PlaylistInfo.add()
    // print(newPlaylist);
    // Playlist.add(createdPlaylist);
    print(Playlist);
    //allPlaylist.add(newPlaylist);
    //allPlaylist.
    // lol.addSong(song: song);
     //= await playlist.add(lol);

    //removing song from a specific playlist


    // List<SongInfo> songs = await audioQuery.getSongs();
    setState(() {
      allPlayList = Playlist;
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Responsive.height(1.5, context),),
              Container(
                height: Responsive.height(8, context),
                child: ListTile(
                  leading: Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        border: NeumorphicBorder(isEnabled: true, color: textColor),
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.all(Radius.circular(5))),
                        color: Colors.transparent,
                        depth: 4,
                        intensity: 0.5,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.favorite_outlined,
                          size: 40,
                          color: Colors.redAccent,
                        ),
                      )
                  ),
                  title: NeumorphicText(
                    'Favourite Songs',
                    textAlign: TextAlign.left,
                    style: NeumorphicStyle(color: textColor),
                    textStyle: NeumorphicTextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: Responsive.height(2.0, context),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.black,
                  ),
                  // trailing: NeumorphicButton(
                  //   onPressed: () {
                  //     print("onClick");
                  //   },
                  //   style: NeumorphicStyle(
                  //     intensity: 5,
                  //     depth: 5,
                  //     shape: NeumorphicShape.convex,
                  //     boxShape: NeumorphicBoxShape.circle(),
                  //     color: Colors.white,
                  //   ),
                  //   child: Icon(
                  //     Icons.more_vert,
                  //     color: Color(primaryColor),
                  //     size: Responsive.width(4, context),
                  //   ),
                  // ),
                ),
              ),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                separatorBuilder: (context, index) => Divider(),
                itemCount: allPlayList.length,
                itemBuilder: (context, index) => Container(
                  height: Responsive.height(7, context),
                  child: ListTile(
                      leading: Neumorphic(
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            border: NeumorphicBorder(isEnabled: true, color: textColor),
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.all(Radius.circular(5))),
                            color: Colors.transparent,
                            depth: 4,
                            intensity: 0.5,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.music_note,
                              size: 40,
                              color: textColor,
                            ),
                          )
                      ),
                      title: NeumorphicText(
                        allPlayList[index].name.length < 30
                            ? allPlayList[index].name
                            : allPlayList[index].name.substring(0, 29) + '...',
                        textAlign: TextAlign.left,
                        style: NeumorphicStyle(color: textColor),
                        textStyle: NeumorphicTextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: Responsive.height(2.0, context),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.black,
                      ),
                      // trailing: NeumorphicButton(
                      //   onPressed: () {
                      //     print("onClick");
                      //   },
                      //   style: NeumorphicStyle(
                      //     intensity: 5,
                      //     depth: 5,
                      //     shape: NeumorphicShape.convex,
                      //     boxShape: NeumorphicBoxShape.circle(),
                      //     color: Colors.white,
                      //   ),
                      //   child: Icon(
                      //     Icons.more_vert,
                      //     color: Color(primaryColor),
                      //     size: Responsive.width(4, context),
                      //   ),
                      // ),

                      onTap: () {
                        // playingSongIndex = index;
                        // playingSongList = [...allPlayList];
                        //
                        // prefs.setString('playingList', 'allSongs');
                        // // prefs.setStringList('playingSongList', playingSongList);
                        // prefs.setInt('playingSongIndex', index);
                        // Navigator.push(context, _createRoute())
                        //     .then((value) {
                        //   // print('activity resumed');
                        //   // setState(() {
                        //   //   prefs.setInt('playingSongIndex', playingSongIndex);
                        //   //   prefs.setInt('repeat', repeat);
                        //   //   prefs.setBool('shuffle', shuffle);
                        //   //   setState(() {
                        //   //     miniPlayerTitle = playingSongList[playingSongIndex].title;
                        //   //     miniPlayerArtist = playingSongList[playingSongIndex].artist;
                        //   //     if(miniPlayerTitle.length>25){
                        //   //       miniPlayerTitle = miniPlayerTitle.substring(0,24)+'...';
                        //   //     }
                        //   //     if(miniPlayerArtist.length>25){
                        //   //       miniPlayerArtist = miniPlayerArtist.substring(0,24)+'...';
                        //   //     }
                        //   //   });
                        //   //   print('${miniPlayerTitle + miniPlayerArtist}');
                        //   // });
                        // });
                      }),
                ),
              ),
            ],
          ),
        ));
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
}
