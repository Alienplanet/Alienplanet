import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:torpedo_player/Screens/player.dart';

import '../ResponsiveConstraints.dart';
import '../main.dart';
import 'frontScreen.dart';

class AlbumInfoScreen extends StatefulWidget {
  final album, albumArt, albumId;

  AlbumInfoScreen({this.album, this.albumArt, this.albumId});

  @override
  _AlbumInfoScreenState createState() => _AlbumInfoScreenState();
}

var albumInfoSongList;

class _AlbumInfoScreenState extends State<AlbumInfoScreen> {
  @override
  void initState() {
    super.initState();
    getList();
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
                    backgroundImage: widget.albumArt
                        == null
                        ? AssetImage('assets/sample_cover.jpg')
                        : FileImage(File(widget.albumArt))as ImageProvider,
                    radius: Responsive.height(10, context),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.height(3, context)),
                child: NeumorphicText(
                  widget.album,
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
                itemCount: albumInfoSongList.length,
                itemBuilder: (context, index) => Container(
                  height: Responsive.height(9, context),
                  child: ListTile(
                      leading: Neumorphic(
                        style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.all(Radius.circular(15))),
                          color: Colors.transparent,
                          depth: 4,
                          intensity: 0.5,
                        ),
                        child: Image(
                          height: Responsive.height(7.0, context),
                          width: Responsive.height(7.0, context),
                          fit: BoxFit.fitWidth,
                          image: albumInfoSongList[index].albumArtwork
                              == null
                              ? AssetImage('assets/sample_cover.jpg')
                              : FileImage(
                                  File(albumInfoSongList[index].albumArtwork)) as ImageProvider,
                         ),
                      ),
                      title: NeumorphicText(
                        albumInfoSongList[index].title.length < 30
                            ? albumInfoSongList[index].title
                            : albumInfoSongList[index].title.substring(0, 29) +
                                '...',
                        textAlign: TextAlign.left,
                        style: NeumorphicStyle(color: Colors.black87),
                        textStyle: NeumorphicTextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: Responsive.height(2.0, context),
                        ),
                      ),
                      subtitle: NeumorphicText(
                        albumInfoSongList[index].artist.length < 25
                            ? albumInfoSongList[index].artist
                            : albumInfoSongList[index].artist.substring(0, 25) +
                                '...',
                        textAlign: TextAlign.left,
                        style: NeumorphicStyle(color: Colors.black87),
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
                        playingSongList = [...albumInfoSongList];

                        prefs.setString('playingList', 'allSongs');
                        // prefs.setStringList('playingSongList', playingSongList);
                        prefs.setInt('playingSongIndex', index);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Player())).then((value) {
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

  void getList() async {
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    var x = await audioQuery.getSongsFromAlbum(albumId: widget.albumId);
    setState(() {
      albumInfoSongList = x;
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
