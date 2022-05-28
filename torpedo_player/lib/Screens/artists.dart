import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../ResponsiveConstraints.dart';
import '../main.dart';
import 'ArtistInfoScreen.dart';

class Artists extends StatefulWidget {
  const Artists() : super();

  @override
  _ArtistsState createState() => _ArtistsState();
}

const gradientStartColor = const Color(0xFF2F2F2F);
const gradientEndColor = const Color(0xFF1A1A1A);

class _ArtistsState extends State<Artists> {
  printArtist() async {
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    List<ArtistInfo> artist = await audioQuery.getArtists(
        sortType: ArtistSortType.LESS_ALBUMS_NUMBER_FIRST);
    setState(() {
      allArtistList = artist;
    }); // returns all artists available
  }

  @override
  void initState() {
    super.initState();
    printArtist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: GridView.builder(
          itemCount: allArtistList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                MediaQuery.of(context).orientation == Orientation.landscape
                    ? 3
                    : 2,
            mainAxisExtent: Responsive.height(27, context),
            crossAxisSpacing: 0,
            mainAxisSpacing: 4,
            childAspectRatio: (1.05 / 1),
          ),
          itemBuilder: (
            context,
            index,
          ) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ArtistInfoScreen(
                          artist: allArtistList[index].name,
                          artistArt: allArtistList[index].artistArtPath,
                          artistId: allArtistList[index].id,
                        )));
              },
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Image(
                          height: Responsive.height(22, context),
                          width: Responsive.height(22, context),
                          fit: BoxFit.cover,
                          image: allArtistList[index].artistArtPath == null
                              ? AssetImage('assets/sample_cover.jpg')
                              : FileImage(
                                  File(allArtistList[index].artistArtPath))as ImageProvider,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: Responsive.height(1, context)),
                        child: Text(
                            allArtistList[index].name.length > 20
                                ? allArtistList[index].name.substring(0, 19) +
                                    '...'
                                : allArtistList[index].name,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                                fontSize: Responsive.height(2, context),
                                color: Colors.black87),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
