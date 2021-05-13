import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:narad/models/user_presentation.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/button_widget.dart';

import 'music_api_saavn.dart';



String status = 'hidden';
AudioPlayer audioPlayer;
PlayerState playerState;

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

class AudioApp extends StatefulWidget {

  const AudioApp({Key key, @required this.friend})
      : super(key: key);

  @override
  AudioAppState createState() => AudioAppState();

  final UserPresentation friend;
}

@override
class AudioAppState extends State<AudioApp> {
  Duration duration;
  Duration position;


  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  get durationText => duration != null ? duration.toString().split('.').first : '';

  get positionText => position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();

    initAudioPlayer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initAudioPlayer() async {
    if (audioPlayer == null) {
      audioPlayer = AudioPlayer();
    }
    setState(() {
      if (checker == "1") {
        stop();
        play();
      }

    });

    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) => {if (mounted) setState(() => position = p)});

    _audioPlayerStateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        {
          if (mounted) setState(() => duration = audioPlayer.duration);
        }
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        if (mounted)
          setState(() {
            position = duration;
          });
      }
    }, onError: (msg) {
      if (mounted)
        setState(() {
          playerState = PlayerState.stopped;
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
    });
  }

  Future play() async {
    await audioPlayer.play(kUrl);
    MediaNotification.showNotification(title: title, author: artist, isPlaying: true);

    if (mounted)
      setState(() {
        playerState = PlayerState.playing;
      });
  }

  Future pause() async {
    await audioPlayer.pause();
    MediaNotification.showNotification(title: title, author: artist, isPlaying: false);

    setState(() {
      playerState = PlayerState.paused;
    });
  }

  Future stop() async {
    await audioPlayer.stop();

    if (mounted)
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    if (mounted)
      setState(() {
        isMuted = muted;
      });
  }

  void onComplete() {
    if (mounted) setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Scaffold(
         body: Container(
           color: Colors.transparent,
             width: deviceData.screenWidth,
             child: Container(
          height: deviceData.screenHeight,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(image),
            ),
          ),

        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepPurple.withOpacity(0.8),
                    Colors.purple.withOpacity(0.6),
                    Colors.black87,
                    Colors.black
                  ]
              )
          ),
          child:
            SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,

            children: [
              Padding(
              padding: const EdgeInsets.only(top: 100.0),
              ),
              Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: Colors.black54,
                    offset: Offset(3, 3),
                    spreadRadius: 0,
                    blurRadius: 20.0,
                  ),],
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(image),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 35.0, bottom: 35),
                child: Column(
                  children: <Widget>[
                    Text(
                      title,
                  style: kTitleTextStyle.copyWith(
                      fontSize: deviceData.screenHeight * 0.015,
                    color: Colors.white.withOpacity(0.4)
                  ),
                      textScaleFactor: 2.5,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        album + "  |  " + artist,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Material(child: _buildPlayer(), color: Colors.transparent, ),
            ],
          ),
        ),
        ),)
        ),)
    );
  }

  Widget _buildPlayer() => Container(
    padding: EdgeInsets.only(top: 15.0, left: 16, right: 16, bottom: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (duration != null)
          Slider(
              activeColor: Colors.purple,
              inactiveColor: Colors.white38,
              value: position?.inMilliseconds?.toDouble() ?? 0.0,
              onChanged: (double value) {
                return audioPlayer.seek((value / 1000).roundToDouble());
              },
              min: 0.0,
              max: duration.inMilliseconds.toDouble()),
        if (position != null) _buildProgressView(),
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple,
                            //Color(0xff00c754),
                            Colors.deepPurpleAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100)),
                    child: playerState==PlayerState.paused || playerState==PlayerState.stopped?
                    IconButton(
                      onPressed: () => play(),
                      iconSize: 40.0,
                      icon: Padding(
                      child: Icon(Feather.play),
                        padding:  EdgeInsets.only(left: 2)),
                      color: Colors.white54,
                    )
                        : IconButton(
                      onPressed: () => pause(),
                      iconSize: 40.0,
                      icon: Icon(Feather.pause),
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Builder(builder: (context) {
                  return RoundedButton(
                      onPressed: () {
                        showBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              decoration: BoxDecoration(color: Color(0xff141414),
                                boxShadow: [BoxShadow(
                                  color: Colors.black54,
                                  offset: Offset(0, -3),
                                  spreadRadius: 0,
                                  blurRadius: 20.0,
                                ),],
                              ),
                              height: 400,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Row(
                                      children: <Widget>[
                                        IconButton(
                                            icon: Icon(
                                              Feather.chevron_down,
                                              color: accent,
                                              size: 40,
                                            ),
                                            onPressed: () => {Navigator.pop(context)}),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 42.0),
                                            child: Center(
                                              child: Text(
                                                "Lyrics",
                                                style: TextStyle(
                                                  color: accent,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  lyrics != "null"
                                      ? Expanded(
                                    flex: 1,
                                    child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Center(
                                          child: SingleChildScrollView(
                                            child: Text(
                                              lyrics,
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: accentLight,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )),
                                  )
                                      : Padding(
                                    padding: const EdgeInsets.only(top: 120.0),
                                    child: Center(
                                      child: Container(
                                        child: Text(
                                          "No Lyrics available ;(",
                                          style: TextStyle(color: accentLight, fontSize: 25),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      },
                      text: "Lyrics",
                      );
                }),
              )
            ],
          ),
        ),
      ],
    ),
  );

  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(
      position != null ? "${positionText ?? ''} ".replaceFirst("0:0", "0") : duration != null ? durationText : '',
      style: TextStyle(fontSize: 18.0, color: Colors.green[50]),
    ),
    Spacer(),
    Text(
      position != null ? "${durationText ?? ''}".replaceAll("0:", "") : duration != null ? durationText : '',
      style: TextStyle(fontSize: 18.0, color: Colors.green[50]),
    )
  ]);
}