import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:torpedo_player/Screens/player.dart';

import '../ResponsiveConstraints.dart';
import '../main.dart';
import 'frontScreen.dart';

TextEditingController searchText = TextEditingController();

class SearchPage extends StatefulWidget {

  @override
  _SearchPageState createState() => _SearchPageState();
}

List<SongInfo> searchList = [];

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    searchFunc('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Card(
              elevation: 15,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Stack(
                  children: [
                    TextField(
                      controller: searchText,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        color: Colors.black
                      ),
                      onChanged: (value){
                        print(value);
                        searchFunc(value);
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(6, 6, 48, 6),
                        prefixIcon: Icon(Icons.search, color: Color(primaryColor),),
                          enabledBorder:OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          focusedBorder:OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(primaryColor), width: 2.0),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        hintText: 'Song search',
                        hintStyle: TextStyle(
                          color: Colors.black38
                        )
                    ),
                      onSubmitted: (value) => searchFunc(value),
                    ),
                    Positioned(
                      right: Responsive.width(2, context),
                      child: IconButton(
                        icon: Icon(Icons.clear, color: Colors.black),
                        onPressed: () {
                          //FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            searchText.text = '';
                            searchList = [...allSongsList];
                          });

                          // Your codes...
                        },
                      ),
                    ),
                  ],
                )
              ),
            ),
            SizedBox(height: Responsive.height(2, context),),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: searchList.length,
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
                            child: searchList[index].albumArtwork == null?
                            Icon(
                              Icons.music_note, size: 40, color: textColor,
                            ):
                            Image(
                              fit: BoxFit.fitHeight,
                              image: FileImage(File(searchList[index].albumArtwork)),
                            )
                        ),
                      ),
                      title: NeumorphicText(
                        searchList[index].title.length < 30
                            ? searchList[index].title
                            : searchList[index].title.substring(0, 29) + '...',
                        textAlign: TextAlign.left,
                        style: NeumorphicStyle(color: textColor),
                        textStyle: NeumorphicTextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: Responsive.height(2.0, context),
                        ),
                      ),
                      subtitle: NeumorphicText(
                        searchList[index].artist.length < 25
                            ? searchList[index].artist
                            : searchList[index].artist.substring(0, 25) + '...',
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
                        playingSongIndex = 0;
                        playingSongList = [...searchList];
                        prefs.setString('playingList', 'allSongs');
                        prefs.setInt('playingSongIndex', index);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Player()));
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

   searchFunc(text) async{
    if(text==''){
      setState(() {
        searchList = [...allSongsList];
      });
    }
    else{
      var temp = await FlutterAudioQuery().searchSongs(query: text);
      setState(() {
        searchList = temp;
      });

    }
  }

}
