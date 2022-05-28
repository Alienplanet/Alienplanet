import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';
import 'package:wave_progress_bars/wave_progress_bars.dart';

import '../ResponsiveConstraints.dart';
import '../main.dart';
import 'allSongs.dart';
import 'equilizer.dart';

class Player extends StatefulWidget {
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  static const int primaryColor = 0xFFb62ef4;

  IconData repeatIcon = Icons.repeat_rounded;

  Duration position = new Duration();
  Duration musicLength = new Duration();

  var timer;
  late Timer _timer;
  var _start = 1000;
  late Timer timer2;

  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    player.seek(newPos);
    position = Duration(seconds: sec);
  }

  void seekToMiliSec(int t) {
    Duration d = Duration(milliseconds: t);
    player.seek(d);
    position = Duration(milliseconds: t);
  }

  static const String testDevice = 'MobileId';

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    nonPersonalizedAds: false,
    keywords: <String>['Songs', 'Music', 'Music Player', 'Tunes'],
  );

  late BannerAd _bannerAd;
  late InterstitialAd _interstitialAd;

  BannerAd createBannerAd() {
    return BannerAd(
        adUnitId: 'ca-app-pub-8377451007717486/9416052641',
        //Change BannerAd adUnitId with Admob ID
        size: AdSize.fullBanner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd $event");
        });
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        adUnitId: 'ca-app-pub-8377451007717486/5521039669',
        //Change Interstitial AdUnitId with Admob ID
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("IntersttialAd $event");
        });
  }

  @override
  void initState() {
    super.initState();

    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-8377451007717486~7348098985');
    //Change appId With Admob Id
    _bannerAd = createBannerAd()
      ..load()
      ..show();

    if (shuffle == null) {
      shuffle = false;
    }
    if (repeat == null) {
      repeat = 0;
    }

    if (shuffle) {
      shuffleList();
    }

    MediaNotification.setListener('select', () {});
    // ignore: deprecated_member_use
    player.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() {
        musicLength = d;
      });
    });
    // player.durationHandler = (d) {
    //   setState(() {
    //     musicLength = d;
    //   });
    // };

    // ignore: deprecated_member_use
    player.onAudioPositionChanged.listen((Duration  p) {
      {
        setState(() => position = p);
  }});
    // player.positionHandler = (p) {
    //   setState(() {
    //     position = p;
    //   });
    //};
    if (playing) {
      player.stop();
      player.release();
      playPressed();
    } else {
      playPressed();
    }

    player.onPlayerCompletion.listen((event) {
      if (repeat == 1) {
        setState(() {
          playingSongIndex += 1;
          seekToSec(0);
          playPressed();
        });
      } else if (repeat == 2) {
        playPressed();
      } else {
        setState(() {
          seekToSec(0);
          playIcon = Icons.play_arrow_rounded;
          playing = false;
        });
        MediaNotification.showNotification(
            title: playingSongList[playingSongIndex].title,
            author: playingSongList[playingSongIndex].artist,
            isPlaying: false);
      }
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  var cwhite = Color(0xFFEAEBF3);
  var cblue = Color(0xFF0A3068);

  final List<double> values = [
    5.0, 15.0, 10.0, 5.0, 8.0, 10.0, 25.0, 35.0, 25.0, 15.0, 8.0, 10.0, 25.0, 35.0, 25.0, 10.0, 8.0, 12.0, 26.0, 22.0, 25.0, 15.0, 13, 32.0, 37.0, 32, 15, 25, 10, 25, 40, 25, 21, 30, 18, 9, 5.0, 15.0, 10.0, 5.0, 10.0, 25.0, 35.0, 25.0, 10.0, 8.0, 12.0, 26.0, 22.0, 25.0, 15.0, 13, 32.0, 37.0, 32, 15, 25, 5.0, 15.0, 10.0, 5.0,
  ];

  Color volumeLabelColor = Colors.transparent;


  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      theme: NeumorphicThemeData(
        //iconTheme: IconThemeData(color: Colors.white),
        baseColor: Color(0xFFFCFCFC),
        lightSource: LightSource.topLeft,
        depth: 5,
      ),
      home: Scaffold(
        backgroundColor: playerBackgroundColor,
        body: LayoutBuilder(builder: (builder, constraints) {
          var isLargePhone = constraints.maxWidth > 350;
          var musicButtonLargeSize = [6.0, 13.0];
          var musicButtonSmallSize = [5.5, 11.0];
          var optionButtonSizeLarge = [10.0];
          var optionButtonSizeSmall = [5];
          var sizedBoxSizeSmall = [1.0, 2.0, 2.0];
          var sizedBoxSizeLarge = [3.0, 1.0, 2.0];
          var marginSmall = [2.0, 1.0];
          var marginLarge = [4.0, 1.5];
          var fontSmall = [1.5, 1.8, 1.7];
          var fontLarge = [2.0, 1.5, 2.0];

          var sizedBoxSize;
          var optionButtonSize;
          var musicButtonSize;
          var marginSize;
          var centerCircle;
          var fontSize;

          if (isLargePhone) {
            musicButtonSize = musicButtonLargeSize;
            optionButtonSize = optionButtonSizeLarge;
            sizedBoxSize = sizedBoxSizeLarge;
            marginSize = marginLarge;
            centerCircle = 12.0;
            fontSize = fontLarge;
          } else {
            musicButtonSize = musicButtonSmallSize;
            optionButtonSize = optionButtonSizeSmall;
            sizedBoxSize = sizedBoxSizeSmall;
            marginSize = marginSmall;
            centerCircle = 7.0;
            fontSize = fontSmall;
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // upper 2 button and playing now text
              Expanded(
                flex: 3,
                child: Align(
                  //alignment: FractionalOffset.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        height: Responsive.height(6, context),
                        child: NeumorphicButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _interstitialAd = createInterstitialAd()
                              ..load()
                              ..show();
                          },
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.circle(),
                              color: _buttonBackground(context)),
                          margin: EdgeInsets.fromLTRB(
                              Responsive.width(optionButtonSize[0], context),
                              0,
                              0,
                              0),
                          // child: SvgPicture.asset(
                          //   'assets/back.svg',
                          //   color: _iconsColor(context),
                          // ),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 30,
                          )
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            0, Responsive.height(sizedBoxSize[1], context), 0, 0),
                        child: NeumorphicText(
                          'PLAYING NOW',
                          curve: Neumorphic.DEFAULT_CURVE,
                          textStyle: NeumorphicTextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: Responsive.height(2, context)),
                          style: NeumorphicStyle(
                            color: _textColor(context),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Responsive.height(10, context),
                        child: NeumorphicButton(
                          onPressed: () {
                            print("onClick");
                          },
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.circle(),
                              color: _buttonBackground(context)),
                          margin: EdgeInsets.fromLTRB(0, 0,
                              Responsive.width(optionButtonSize[0], context), 0),
                          child: SvgPicture.asset(
                            'assets/menu.svg',
                            color: _iconsColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //the picture and shadow
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 100,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        right: 0,
                        left: 0,
                        bottom: 0,
                        top: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Neumorphic(
                            padding:
                                EdgeInsets.all(Responsive.height(8, context)),
                            style: NeumorphicStyle(
                                border: NeumorphicBorder(
                                    width: 0, color: Colors.white),
                                shape: NeumorphicShape.flat,
                                depth: 10,
                                // color: Colors.,
                                boxShape: NeumorphicBoxShape.circle(),
                                shadowDarkColor: Color(0xFF626262)),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        left: 0,
                        bottom: 0,
                        top: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Container(
                            decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                            fit: BoxFit.cover,
                              scale: 1,
                              image: playingSongList[playingSongIndex].albumArtwork
                              // playingSongList[playingSongIndex]
                              //             .albumArtwork ==
                              //         null
                              //     ? AssetImage('assets/sample_cover.jpg')
                              //     : FileImage(File(
                              //         playingSongList[playingSongIndex]
                              //             .albumArtwork))
                            )
                            )),
                          ),
                          // child: CircleAvatar(
                          //   backgroundImage: playingSongList[playingSongIndex]
                          //               .albumArtwork ==
                          //           null
                          //       ? AssetImage('assets/sample_cover.jpg')
                          //       : FileImage(File(
                          //           playingSongList[playingSongIndex]
                          //               .albumArtwork)),
                          //   radius: Responsive.height(3, context),
                          // ),
                        ),
                      Positioned(
                        right: 0,
                        left: 0,
                        bottom: 0,
                        top: 0,
                        child: Container(
                          child: SleekCircularSlider(
                            appearance: CircularSliderAppearance(
                                customColors: CustomSliderColors(
                                  dynamicGradient: true,
                                  trackColors: [
                                     const Color(0XFFFCE4EC),
                                    const Color(0XE3F2FD),

                                  ],
                                  progressBarColors: [
                                    Colors.purpleAccent,
                                    Colors.purple
                                  ],
                                  dotColor: Color(0xFFE3E0E0),
                                ),
                                startAngle: 180,
                                angleRange: 180,
                                infoProperties: InfoProperties(
                                    modifier: (double lol) {
                                      return lol.toInt().toString();
                                    },
                                    mainLabelStyle: TextStyle(
                                        color: volumeLabelColor, fontSize: 50)),
                                customWidths: CustomSliderWidths(
                                  progressBarWidth: 5,
                                  trackWidth: 5,
                                  handlerSize: 10,
                                )),
                            min: 0,
                            max: 100,
                            onChange: (double value) {
                              setState(() {
                                // TODO: Volume setter
                                volumeLabelColor = Colors.black38;
                                player.setVolume(value);
                              });
                            },
                            onChangeEnd: (double value) {
                              volumeLabelColor = Colors.transparent;
                              player.setVolume(value);
                            },
                          ),
                        ),
                      ),
                      // Positioned(
                      //   right: 0,
                      //   left: 0,
                      //   bottom: 0,
                      //   top: 0,
                      //   child: AnimatedOpacity(
                      //     opacity: playing ? 0 : 1,
                      //     duration: Duration(milliseconds: 500),
                      //     child: IconButton(
                      //       onPressed: () {
                      //         if (!playing) {
                      //           playPressed();
                      //         } else {
                      //           pausePressed();
                      //         }
                      //       },
                      //       icon: Icon(
                      //         playIcon,
                      //         color: Colors.white70,
                      //         size: Responsive.width(musicButtonSize[1], context),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              // Label and artist
              Expanded(
                flex: 0,
                child: Align(
                  //alignment: FractionalOffset.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap:(){
                          Fluttertoast.showToast(
                              msg: "Coming Soon...\nFeature under development",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black54,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        },
                        child: SizedBox(
                          height: Responsive.height(10, context),
                          width: Responsive.width(8, context),
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient:  LinearGradient(
                                colors: <Color>[
                                  Colors.purple,
                                  Colors.purpleAccent,
                                ],
                              ),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/ringtone_cutter.svg',
                                color: Colors.white,
                                //size: Responsive.height(3, context),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: NeumorphicText(
                              playingSongList[playingSongIndex].title.length < 30?
                              playingSongList[playingSongIndex].title:
                              playingSongList[playingSongIndex].title.substring(0, 29) + '...',
                              curve: Neumorphic.DEFAULT_CURVE,
                              textStyle: NeumorphicTextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Responsive.height(fontSize[0], context),
                              ),
                              style: NeumorphicStyle(
                                color: _textColor(context),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0, Responsive.height(marginSize[1], context), 0, 0),
                            child: NeumorphicText(
                              playingSongList[playingSongIndex].artist == '<unknown>'
                                  ? 'Unknown Artist'
                                  : playingSongList[playingSongIndex].artist.length < 30?
                              playingSongList[playingSongIndex].artist:
                              playingSongList[playingSongIndex].artist.substring(0, 29) + '...',
                              curve: Neumorphic.DEFAULT_CURVE,
                              textStyle: NeumorphicTextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: Responsive.height(fontSize[1], context)),
                              style: NeumorphicStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>EqualizerPage()));
                        },
                        child: SizedBox(
                          height: Responsive.height(10, context),
                          width: Responsive.width(8, context),
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient:  LinearGradient(
                                colors: <Color>[
                                  Colors.purpleAccent,
                                  Colors.purple
                                ],
                              ),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
                              alignment: Alignment.center,
                                child: SvgPicture.asset(
                                 'assets/equaliser.svg',
                                  color: Colors.white,
                                  // size: Responsive.height(3, context),
                                ),
                            ),
                          ),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              // Duration 0:00 3:14 and the slider
              Expanded(
                flex: 2,
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                Responsive.height(1.5, context), 0, 0, 0),
                            child: NeumorphicText(
                              getTime(),
                              curve: Neumorphic.DEFAULT_CURVE,
                              textStyle: NeumorphicTextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: Responsive.height(fontSize[2], context),
                              ),
                              style: NeumorphicStyle(
                                color: Color(primaryColor),
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              Positioned(
                                bottom: Responsive.height(2, context),
                                child: WaveProgressBar(
                                  progressPercentage: (position.inSeconds.toDouble() /
                                      musicLength.inSeconds.toDouble() *
                                      100)
                                      .isNaN
                                      ? 0
                                      : position.inSeconds.toDouble() /
                                      musicLength.inSeconds.toDouble() *
                                      100,
                                  listOfHeights: values,
                                  width: Responsive.width(70, context),
                                  initalColor: Colors.grey[350],
                                  progressColor: Color(primaryColor),
                                  backgroundColor: Colors.white,
                                  timeInMilliSeconds: 100000,
                                  isHorizontallyAnimated: false,
                                  isVerticallyAnimated: false,
                                ),
                              ),
                              Opacity(
                                opacity: 0,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: SizedBox(
                                    width: Responsive.width(70, context),
                                    //height: Responsive.height(20, context),
                                    child: FlutterSlider(
                                      values: [position.inSeconds.toDouble()],
                                      min: 0,
                                      max: musicLength.inSeconds.toDouble(),
                                      //tip when slider moving
                                      tooltip: FlutterSliderTooltip(
                                          textStyle: TextStyle(
                                              fontSize: 13, color: Colors.transparent),
                                          boxStyle: FlutterSliderTooltipBox(
                                              decoration:
                                              BoxDecoration(color: Colors.transparent))),
                                      // whole bar
                                      trackBar: FlutterSliderTrackBar(
                                        inactiveTrackBar: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.black12,
                                          border: Border.all(width: 10, color: Colors.black87),
                                          boxShadow: [
                                            new BoxShadow(
                                              color: Color(0XFF171717),
                                              offset: Offset(-3.0, -3.0),
                                              blurRadius: 3.0,
                                            ),
                                            new BoxShadow(
                                              color: Color(0XFF404040),
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 0.5,
                                            ),
                                          ],
                                        ),
                                        activeTrackBar: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: [
                                            new BoxShadow(
                                              color: Color(0XFF171717),
                                              offset: Offset(-3.0, -3.0),
                                              blurRadius: 3.0,
                                            ),
                                            new BoxShadow(
                                              color: Color(0XFF404040),
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 3.0,
                                            ),
                                          ],
                                          gradient: LinearGradient(
                                            colors: [Color(0xFF00C9FF), Color(0xFF92fe9d)],
                                          ),
                                        ),
                                      ),
                                      //center circle
                                      handler: FlutterSliderHandler(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0XFF1c1c1c),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.all(11),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0XFF212121),
                                              boxShadow: [
                                                new BoxShadow(
                                                  color: Color(0XFF1c1c1c),
                                                  offset: Offset(3.0, 3.0),
                                                  blurRadius: 5.0,
                                                ),
                                                new BoxShadow(
                                                  color: Color(0XFF404040),
                                                  offset: Offset(-3.0, -3.0),
                                                  blurRadius: 5.0,
                                                ),
                                              ],
                                            ),
                                            child: Container(
//                      height: 1 * Responsive.heightMultiplier,
                                              decoration: BoxDecoration(
                                                color: Color(primaryColor),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  new BoxShadow(
                                                    color: Color(0XFF1c1c1c),
                                                    offset: Offset(5.0, 5.0),
                                                    blurRadius: 10.0,
                                                  ),
                                                  new BoxShadow(
                                                    color: Color(0XFF404040),
                                                    offset: Offset(-5.0, -5.0),
                                                    blurRadius: 10.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onDragging: (handlerIndex, lowerValue, upperValue) {
                                        setState(() {
                                          seekToSec(lowerValue.toInt());
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0, 0, Responsive.height(1.5, context), 0),
                            child: NeumorphicText(
                              getEnd(),
                              curve: Neumorphic.DEFAULT_CURVE,
                              textStyle: NeumorphicTextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize:
                                      Responsive.height(fontSize[2], context)),
                              style: NeumorphicStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // 5 buttons
              Expanded(
                flex: 4,
                child: Align(
                  //alignment: FractionalOffset.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: Responsive.width(10, context),
                      ),
                      // repeat
                      NeumorphicButton(
                        onPressed: () {
                          if (repeat == 1) {
                            repeat += 1;
                            setState(() {
                              repeatIcon = Icons.repeat_one_rounded;
                            });
                          } else if (repeat == 2) {
                            repeat = 0;
                            setState(() {
                              repeatIcon = Icons.repeat_rounded;
                            });
                          } else {
                            setState(() {
                              repeat += 1;
                            });
                          }
                        },
                        style: NeumorphicStyle(
                            shape: NeumorphicShape.convex,
                            boxShape: NeumorphicBoxShape.circle(),
                            color: _buttonBackground(context)),
                        child: Icon(
                          repeat == 2 ? Icons.repeat_one_rounded : repeatIcon,
                          color: repeat == 0
                              ? _iconsColor(context)
                              : Color(primaryColor),
                          size: Responsive.width(musicButtonSize[0], context),
                        ),
                      ),
                      // previous
                      GestureDetector(

                        onLongPressStart: (value){
                          timer = Timer(Duration(milliseconds: 100), startBackTimer);
                        },
                        onLongPressEnd: (value){
                          print('long end: ' + value.toString());
                        },
                        onLongPressUp: (){
                          print('removed');
                          timer.cancel();
                          _timer.cancel();
                          _start = 1000;
                        },
                        child: NeumorphicButton(
                          onPressed: () {
                            setState(() {
                              if (playingSongIndex > 0) {
                                if (position.inSeconds.toDouble() > 5.0) {
                                  // print(position.inSeconds.toDouble().toString());
                                  seekToSec(0);
                                } else {
                                  setState(() {
                                    playingSongIndex -= 1;
                                    seekToSec(0);
                                    playPressed();
                                  });
                                }
                              }
                              seekToSec(0);
                              playPressed();
                            });
                          },
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.circle(),
                              color: _buttonBackground(context)),
                          child: Icon(
                            Icons.fast_rewind,
                            color: _iconsColor(context),
                            size: Responsive.width(musicButtonSize[0], context),
                          ),
                        ),
                      ),
                      //play pause
                      NeumorphicButton(
                        onPressed: () {
                          if (!playing) {
                            playPressed();
                          } else {
                            pausePressed();
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
                          size: Responsive.width(musicButtonSize[1], context),
                        ),
                      ),
                      // play pause
                      // next
                      // ElevatedButton(
                      //   onLongPress: ()=>print('longPress'),
                      //     onPressed: ()=>print('justPress'),
                      //       child: Icon(
                      //         Icons.fast_forward,
                      //         color: _iconsColor(context),
                      //         size: Responsive.width(musicButtonSize[0], context),
                      //       ),
                      // ),
                      // next
                      GestureDetector(
                        onLongPressStart: (value){
                          timer = Timer(Duration(milliseconds: 100), startTimer);
                        },
                        onLongPressEnd: (value){
                          print('long end: ' + value.toString());
                        },
                        onLongPressUp: (){
                          print('removed');
                          timer.cancel();
                          _timer.cancel();
                          _start = 1000;
                        },
                        child: NeumorphicButton(
                          provideHapticFeedback: false,
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.circle(),
                              color: _buttonBackground(context)),
                          onPressed: (){
                            setState(() {
                              playingSongIndex += 1;
                              seekToSec(0);
                              playPressed();
                            });
                          },
                          child: Icon(
                            Icons.fast_forward,
                            color: _iconsColor(context),
                            size: Responsive.width(musicButtonSize[0], context),
                          ),
                        ),
                      ),
                      // shuffle
                      NeumorphicButton(
                        onPressed: () async {
                          if (shuffle) {
                            setState(() {
                              shuffle = false;
                              shuffleBack();
                            });
                          } else {
                            setState(() {
                              shuffle = true;
                              shuffleList();
                            });
                          }
                        },
                        style: NeumorphicStyle(
                            shape: NeumorphicShape.convex,
                            boxShape: NeumorphicBoxShape.circle(),
                            color: _buttonBackground(context)),
                        child: Icon(
                          Icons.shuffle,
                          color: shuffle
                              ? Color(primaryColor)
                              : _iconsColor(context),
                          size: Responsive.width(musicButtonSize[0], context),
                        ),
                      ),
                      SizedBox(
                        width: Responsive.width(10, context),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          );
        })),
    );
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

  String getTime() {
    if (position.inSeconds.remainder(60) < 10)
      return '${position.inMinutes}:0${position.inSeconds.remainder(60)}';
    else
      return '${position.inMinutes}:${position.inSeconds.remainder(60)}';
  }

  String getEnd() {
    if (musicLength.inSeconds.remainder(60) < 10)
      return "${musicLength.inMinutes}:0${musicLength.inSeconds.remainder(60)}";
    else
      return "${musicLength.inMinutes}:${musicLength.inSeconds.remainder(60)}";
  }

  playPressed() {
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

  pausePressed() {
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

  void shuffleList() {
    lastList = [...playingSongList];
    var random = new Random();

    var temp = playingSongList[0];
    playingSongList[0] = playingSongList[playingSongIndex];
    playingSongList[playingSongIndex] = temp;

    playingSongIndex = 0;

    for (int i = 1; i < playingSongList.length; i++) {
      var rn = random.nextInt(playingSongList.length - 1) + 1;
      var temp = playingSongList[i];
      setState(() {
        playingSongList[i] = playingSongList[rn];
        playingSongList[rn] = temp;
      });
    }
  }

  void shuffleBack() {
    for (int i = 0; i < lastList.length; i++) {
      if (lastList[i].filePath == playingSongList[playingSongIndex].filePath) {
        setState(() {
          playingSongIndex = i;
          playingSongList = lastList;
        });
        break;
      }
    }
  }

  void startTimer() {
    Vibration.vibrate(duration: 300);
    const oneSec = const Duration(milliseconds: 100);
    _timer = new Timer.periodic(
      oneSec,
      (timer2) {
        if (_start == 0) {
          setState(() {
            print('timerClosed');
            timer2.cancel();
          });
        } else {
          setState(() {
            seekToMiliSec(position.inMilliseconds.toInt() + 20000);
            //seekToSec(position.inSeconds.toInt()+1);
            _start--;
          });
        }
      },
    );
  }

  void cancelTimer(Timer timer) {}
  void startBackTimer() {
    Vibration.vibrate(duration: 300);
    const oneSec = const Duration(milliseconds: 100);
    _timer = new Timer.periodic(
      oneSec,
          (timer2) {
        if (_start == 0) {
          setState(() {
            print('timerClosed');
            timer2.cancel();
          });
        } else {
          setState(() {
            seekToMiliSec(position.inMilliseconds.toInt() - 5000);
            _start--;
          });
        }
      },
    );
  }
}