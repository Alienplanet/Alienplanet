
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'LifeCycleManager.dart';
import 'Screens/frontScreen.dart';


void main() {
  runApp((MyApp()));
}

const PrimaryColor = const Color(0xFF1A1A1A);
const AccentColor = const Color(0xFF2cffba);
const Color textColor = Colors.black;

AudioPlayer player = AudioPlayer();
AudioCache cache = AudioCache(fixedPlayer: player);

List<SongInfo> allSongsList = [];
List<ArtistInfo> allArtistList = [];
List<AlbumInfo> allAlbumList = [];
List<PlaylistInfo> allPlayList = [];

bool playing = false;

const int primaryColor = 0xFFb62ef4;

int playingSongIndex = 0;
List playingSongList = [];

List lastList = [];

bool shuffle = false;
int repeat = 0;

String playingList = [].toString();

String status = 'hidden';

Color playerBackgroundColor = Color(0xFFFFFFFF);
IconData playIcon = Icons.play_arrow_rounded;

class MyApp extends StatelessWidget with WidgetsBindingObserver{
  @override
  Widget build(BuildContext context) {
    return LifeCycleManager(
      child: NeumorphicApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: NeumorphicThemeData(
          baseColor: Color(0xffc552fa),
          lightSource: LightSource.topLeft,
          shadowLightColor: Colors.white54,
          depth: 5,
        ),
        home: FrontScreen(),
      ),
    );
  }
}