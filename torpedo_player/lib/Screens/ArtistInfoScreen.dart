import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:torpedo_player/Screens/player.dart';

import '../ResponsiveConstraints.dart';
import '../main.dart';
import 'frontScreen.dart';

class ArtistInfoScreen extends StatefulWidget {
  final artist, artistArt, artistId;

  ArtistInfoScreen({this.artist, this.artistArt, this.artistId});

  @override
  _ArtistInfoScreenState createState() => _ArtistInfoScreenState();
}

var artistInfoSongList;

const gradientStartColor = const Color(0xFF2F2F2F);
const gradientEndColor = const Color(0xFF1A1A1A);

List<AlbumInfo> artistAlbum = [];

class _ArtistInfoScreenState extends State<ArtistInfoScreen> {
  @override
  void initState() {
    super.initState();
    loadList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    height: Responsive.height(7, context),
                    child: NeumorphicButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.convex,
                          boxShape: NeumorphicBoxShape.circle(),
                          color: _buttonBackground(context)),
                      margin: EdgeInsets.fromLTRB(
                          Responsive.width(7, context),
                          Responsive.height(2, context),
                          0,
                          0),
                      child: SvgPicture.asset(
                        'assets/back.svg',
                        color: _iconsColor(context),
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  Neumorphic(
                    padding: EdgeInsets.all(Responsive.height(10.0, context)),
                    style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        depth: 10,
                        border: NeumorphicBorder(
                            isEnabled: true,
                            width: Responsive.height(0.0, context),
                            color: Colors.black12),
                        boxShape: NeumorphicBoxShape.circle(),
                        shadowDarkColor: Color(0xFF626262)),
                  ),
                  CircleAvatar(
                    backgroundImage: widget.artistArt == null
                        ? AssetImage('assets/sample_cover.jpg')
                        : FileImage(File(widget.artistArt)) as ImageProvider,
                    radius: Responsive.height(10, context),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.height(3, context)),
                child: NeumorphicText(
                  widget.artist,
                  curve: Neumorphic.DEFAULT_CURVE,
                  textStyle: NeumorphicTextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: Responsive.height(3, context)),
                  style: NeumorphicStyle(
                    color: _textColor(context),
                  ),
                ),
              ),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                separatorBuilder: (context, index) => Divider(),
                itemCount: artistInfoSongList.length,
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
                            child: artistInfoSongList[index].albumArtwork == null?
                            Icon(
                              Icons.music_note, size: 40, color: textColor,
                            ):
                            Image(
                              fit: BoxFit.fitHeight,
                              image: FileImage(File(artistInfoSongList[index].albumArtwork)),
                            )
                        ),
                      ),
                      title: NeumorphicText(
                        artistInfoSongList[index].title.length < 30
                            ? artistInfoSongList[index].title
                            : artistInfoSongList[index].title.substring(0, 29) +
                                '...',
                        textAlign: TextAlign.left,
                        style: NeumorphicStyle(color: Colors.black87),
                        textStyle: NeumorphicTextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: Responsive.height(2.0, context),
                        ),
                      ),
                      subtitle: NeumorphicText(
                        artistInfoSongList[index].artist.length < 25
                            ? artistInfoSongList[index].artist
                            : artistInfoSongList[index].artist.substring(0, 25) +
                                '...',
                        textAlign: TextAlign.left,
                        style: NeumorphicStyle(color: Colors.black87),
                        textStyle: NeumorphicTextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: Responsive.height(2.0, context),
                        ),
                      ),
                      trailing:  NeumorphicButton(
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
                        playingSongList = [...artistInfoSongList];

                        prefs.setString('playingList', 'allSongs');
                        // prefs.setStringList('playingSongList', playingSongList);
                        prefs.setInt('playingSongIndex', index);
                        Navigator.push(context,
                                MaterialPageRoute(builder: (context) => Player()))
                            .then((value) {
                          print('activity resumed');
                          setState(() {
                            prefs.setInt('playingSongIndex', playingSongIndex);
                            prefs.setInt('repeat', repeat);
                            prefs.setBool('shuffle', shuffle);
                          });
                        });
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loadList() async {
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    var x = await audioQuery.getSongsFromArtist(artistId: widget.artistId);
    setState(() {
      artistInfoSongList = x;
    });
  }

  Color _iconsColor(BuildContext context) {
    final theme = NeumorphicTheme.of(context);
    if (theme!.isUsingDark) {
      return Colors.black;
    } else {
      return Colors.black;
    }
  }

  Color _buttonBackground(BuildContext context) {
    final theme = NeumorphicTheme.of(context);
    if (theme!.isUsingDark) {
      return Colors.white38;
    } else {
      return Colors.white38;
    }
  }

  Color _textColor(BuildContext context) {
    if (NeumorphicTheme.isUsingDark(context)) {
      return Colors.black;
    } else {
      return Colors.black;
    }
  }

}
