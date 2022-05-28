import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../ResponsiveConstraints.dart';
import '../main.dart';
import 'AlbumInfoScreen.dart';
class Albums extends StatefulWidget {
  const Albums() : super();

  @override
  _AlbumsState createState() => _AlbumsState();
}

const gradientStartColor = const Color(0xFF2F2F2F);
const gradientEndColor = const Color(0xFF1A1A1A);

class _AlbumsState extends State<Albums> {
  printAlbum() async {
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();

    List<AlbumInfo> album = await audioQuery.getAlbums(sortType: AlbumSortType.ALPHABETIC_ARTIST_NAME);
    setState(() {
      allAlbumList = album;
    }); // returns all artists available
  }

  @override
  void initState() {
    super.initState();
    printAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body:GridView.builder(
          itemCount: allAlbumList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            MediaQuery.of(context).orientation == Orientation.landscape
                ? 3
                : 2,
            mainAxisExtent: Responsive.height(25, context),
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            childAspectRatio: (1.05 / 1),
          ),
          itemBuilder: (
              context,
              index,
              ) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AlbumInfoScreen(album:allAlbumList[index].title, albumArt:  allAlbumList[index].albumArt, albumId: allAlbumList[index].id,)));
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image(
                        height: Responsive.height(20, context),
                        width: Responsive.height(20, context),
                        fit: BoxFit.cover,
                       image: allAlbumList[index].albumArt
                            == null
                            ? AssetImage('assets/sample_cover.jpg')
                            : FileImage(
                            File(allAlbumList[index].albumArt)) as ImageProvider,
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: Responsive.height(1, context)),
                      child: Text(
                          allAlbumList[index].title.length > 20
                              ? allAlbumList[index].title.substring(0, 19) +
                              '...'
                              : allAlbumList[index].title,
                          style: TextStyle(
                              fontSize: Responsive.height(2, context),
                              color: Colors.black),
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
