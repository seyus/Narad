import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:narad/models/user.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/popup_menu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'mback_icon.dart';
import 'music.dart';
import 'music_api_saavn.dart';
import 'music_popup_menu.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({
    Key key,
    @required this.user,
  }) : super(key: key);

  final MUser user;

  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<MusicScreen> {
  TextEditingController searchBar = TextEditingController();
  bool fetchingSongs = false;

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xff1c252a),
      statusBarColor: Colors.transparent,
    ));

    MediaNotification.setListener('play', () {
      setState(() {
        playerState = PlayerState.playing;
        status = 'play';
        audioPlayer.play(kUrl);
      });
    });

    MediaNotification.setListener('pause', () {
      setState(() {
        playerState = PlayerState.paused;
        status = 'pause';
        audioPlayer.pause();
      });
    });

    MediaNotification.setListener("close", () {
      audioPlayer.stop();
      dispose();
      checker = "0";
      MediaNotification.hideNotification();
    });
  }

  search() async {
    String searchQuery = searchBar.text;
    if (searchQuery.isEmpty) return;
    fetchingSongs = true;
    setState(() {});
    await fetchSongsList(searchQuery);
    fetchingSongs = false;
    setState(() {});
  }

  getSongDetails(String id, var context) async {
    try {
      await fetchSongDetails(id);
      print(kUrl);
    } catch (e) {
      artist = "Unknown";
      print(e);
    }
    setState(() {
      checker = "1";
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioApp(friend: widget.user),
      ),
    );
  }

  downloadSong(id) async {
    String filepath;
    String filepath2;
    var status = await Permission.storage.status;
    if (status.isDenied) {
      // code of read or write file in external storage (SD card)
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      debugPrint(statuses[Permission.storage].toString());
    }
    status = await Permission.storage.status;
    await fetchSongDetails(id);
    if (status.isGranted) {
      ProgressDialog pr = ProgressDialog(context);
      pr = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: false,
        showLogs: false,
      );

      pr.style(
        backgroundColor: Color(0xff263238),
        elevation: 4,
        textAlign: TextAlign.left,
        progressTextStyle: TextStyle(color: Colors.white),
        message: "Downloading " + title,
        messageTextStyle: TextStyle(color: accent),
        progressWidget: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      );
      await pr.show();

      final filename = title + ".m4a";
      final artname = title + "_artwork.jpg";
      //Directory appDocDir = await getExternalStorageDirectory();
      String dlPath = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_MUSIC);
      await File(dlPath + "/" + filename).create(recursive: true).then((value) => filepath = value.path);
      await File(dlPath + "/" + artname).create(recursive: true).then((value) => filepath2 = value.path);
      debugPrint('Audio path $filepath');
      debugPrint('Image path $filepath2');
      if (has_320 == "true") {
        kUrl = rawkUrl.replaceAll("_96.mp4", "_320.mp4");
        final client = http.Client();
        final request = http.Request('HEAD', Uri.parse(kUrl))..followRedirects = false;
        final response = await client.send(request);
        debugPrint(response.statusCode.toString());
        kUrl = (response.headers['location']);
        debugPrint(rawkUrl);
        debugPrint(kUrl);
        final request2 = http.Request('HEAD', Uri.parse(kUrl))..followRedirects = false;
        final response2 = await client.send(request2);
        if (response2.statusCode != 200) {
          kUrl = kUrl.replaceAll(".mp4", ".mp3");
        }
      }
      var request = await HttpClient().getUrl(Uri.parse(kUrl));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      File file = File(filepath);

      var request2 = await HttpClient().getUrl(Uri.parse(image));
      var response2 = await request2.close();
      var bytes2 = await consolidateHttpClientResponseBytes(response2);
      File file2 = File(filepath2);

      await file.writeAsBytes(bytes);
      await file2.writeAsBytes(bytes2);
      debugPrint("Started tag editing");

      final tag = Tag(
        title: title,
        artist: artist,
        artwork: filepath2,
        album: album,
        lyrics: lyrics,
        genre: null,
      );

      debugPrint("Setting up Tags");
      final tagger = Audiotagger();
      await tagger.writeTags(
        path: filepath,
        tag: tag,
      );
      await Future.delayed(const Duration(seconds: 1), () {});
      await pr.hide();

      if (await file2.exists()) {
        await file2.delete();
      }
      debugPrint("Done");
      EdgeAlert.show(context,
          title: 'Download Complete',
          gravity: EdgeAlert.BOTTOM,
          icon: Icons.check_rounded,
          backgroundColor: Colors.purple);
    } else if (status.isDenied || status.isPermanentlyDenied) {
      EdgeAlert.show(context,
          title: 'Download Failed',
          description: "Storage Permission Denied\nAllow Storage Access to Download",
          gravity: EdgeAlert.BOTTOM,
          icon: Icons.error,
          backgroundColor: Colors.red);
    } else {
      EdgeAlert.show(context,
          title: 'Download Failed',
          description: "Permission Error!",
          gravity: EdgeAlert.BOTTOM,
          icon: Icons.error,
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Container(
      color: Color(0xff141414),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        //backgroundColor: Color(0xff384850),
        bottomNavigationBar: kUrl != ""
            ? Stack(
            children: [
              ClipRRect(
                  child: Container(
          height: 75,
          //color: Color(0xff1c252a),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              image: CachedNetworkImageProvider(image),
            ),
          ),
          child: new BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: new Container(
              decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
            ),
          ),
        ),),
          Container(
            height: 75,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Colors.black54,
                      Colors.white38
                    ]

                )
              ),
              child: Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 2),
            child: GestureDetector(
              onTap: () {
                checker = "0";
                if (kUrl != "") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AudioApp(friend: widget.user)),
                  );
                }
                FocusScope.of(context).unfocus();
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0.0,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Feather.chevron_up,
                        size: 30,
                      ),
                      onPressed: null,
                      disabledColor: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 7, bottom: 7, right: 15),
                    //child: Image.network("https://sgdccdnems06.cdnsrv.jio.com/c.saavncdn.com/830/Music-To-Be-Murdered-By-English-2020-20200117040807-500x500.jpg"),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          artist,
                          style: TextStyle(color: Colors.white54, fontSize: 15),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: playerState == PlayerState.playing ? Icon(Feather.pause) : Icon(Feather.play),
                    color: accent,
                    splashColor: Colors.transparent,
                    onPressed: () {
                      setState(() {
                        if (playerState == PlayerState.playing) {
                          audioPlayer.pause();
                          playerState = PlayerState.paused;
                          MediaNotification.showNotification(title: title, author: artist, isPlaying: false);
                        } else if (playerState == PlayerState.paused) {
                          audioPlayer.play(kUrl);
                          playerState = PlayerState.playing;
                          MediaNotification.showNotification(title: title, author: artist, isPlaying: true);
                        }
                      });
                    },
                    iconSize: 45,
                  )
                ],
              ),
            ),
          ),)],
        )
            : SizedBox.shrink(),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 30, bottom: 20.0)),
              Center(
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(height: deviceData.screenHeight * 0.01),
                    Text(
                      "N  A  R  A  D",
                      style: kTitleTextStyle.copyWith(
                          fontSize: deviceData.screenHeight * 0.028,
                          foreground: Paint()..shader = linearGradient
                      ),
                    ),
                    MusicPopUpMenu(user: widget.user),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 30)),
              TextField(
                onSubmitted: (String value) {
                  search();
                },
                controller: searchBar,
                style: TextStyle(
                  fontSize: 16,
                  color: accent,
                ),
                cursorColor: Colors.green[50],
                decoration: InputDecoration(
                  fillColor: Colors.black,
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                    borderSide: BorderSide(color: accent),
                  ),
                  suffixIcon: IconButton(
                    icon: fetchingSongs
                        ? SizedBox(
                      height: 18,
                      width: 18,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                    )
                        : Icon(
                      Feather.search,
                      color: Colors.white,
                    ),
                    color: accent,
                    onPressed: () {
                      search();
                    },
                  ),
                  border: InputBorder.none,
                  hintText: "Search...",
                  hintStyle: TextStyle(
                    color: Colors.grey[800],
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 18,
                    right: 20,
                    top: 14,
                    bottom: 14,
                  ),
                ),
              ),
              searchedList.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: searchedList.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Card(
                      color: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: () {
                          getSongDetails(searchedList[index]["id"], context);
                        },
                        onLongPress: () {
                          topSongs();
                        },
                        splashColor: accent,
                        hoverColor: accent,
                        focusColor: accent,
                        highlightColor: accent,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Feather.music,
                                  size: 30,
                                  color: accent,
                                ),
                              ),
                              title: Text(
                                (searchedList[index]['title']).toString().split("(")[0].replaceAll("&quot;", "\"").replaceAll("&amp;", "&"),
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                searchedList[index]['more_info']["singers"],
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                color: accent,
                                icon: Icon(Feather.download),
                                onPressed: () => downloadSong(searchedList[index]["id"]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
                  : Container(),
              FutureBuilder(
                future: topTrendingSongs(),
                builder: (context, data) {
                  if (data.hasData)
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0, bottom: 10, left: 8),
                            child: Text(
                              "Trending Now",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                          Container(
                            //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            height: MediaQuery.of(context).size.height * 0.22,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,

                              shrinkWrap: true,
                              itemCount: 50,
                              itemBuilder: (context, index) {
                                return getTopSong(
                                    data.data[index]["image"], data.data[index]["title"], data.data[index]["more_info"]["artistMap"]["primary_artists"][0]["name"], data.data[index]["id"]);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(35.0),
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ));
                },
              ),
              FutureBuilder(
                future: topEngTrendingSongs(),
                builder: (context, data) {
                  if (data.hasData)
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          Container(
                            //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            height: MediaQuery.of(context).size.height * 0.22,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,

                              shrinkWrap: true,
                              itemCount: 30,
                              itemBuilder: (context, index) {
                                return getTopSong(
                                    data.data[index]["image"], data.data[index]["title"], data.data[index]["more_info"]["artistMap"]["primary_artists"][0]["name"], data.data[index]["id"]);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(35.0),
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ));
                },
              ),
              FutureBuilder(
                future: topBollyTrendingSongs(),
                builder: (context, data) {
                  if (data.hasData)
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0, bottom: 10, left: 8),
                            child: Text(
                              "Bollywood Trending",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 22,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            height: MediaQuery.of(context).size.height * 0.22,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,

                              shrinkWrap: true,
                              itemCount: 20,
                              itemBuilder: (context, index) {
                                return getTopSong(
                                    data.data[index]["image"], data.data[index]["title"], data.data[index]["more_info"]["artistMap"]["primary_artists"][0]["name"], data.data[index]["id"]);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(35.0),
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ));
                },
              ),
              FutureBuilder(
                future: topSongs(),
                builder: (context, data) {
                  if (data.hasData)
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0, bottom: 10, left: 8),
                            child: Text(
                              "Top Songs",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 22,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            height: MediaQuery.of(context).size.height * 0.22,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 30,
                              itemBuilder: (context, index) {
                                return getTopSong(
                                    data.data[index]["image"], data.data[index]["title"], data.data[index]["more_info"]["artistMap"]["primary_artists"][0]["name"], data.data[index]["id"]);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(35.0),
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTopSong(String image, String title, String subtitle, String id) {
    return InkWell(
      onTap: () {
        getSongDetails(id, context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
          child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.17,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(image),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            title.split("(")[0].replaceAll("&amp;", "&").replaceAll("&#039;", "'").replaceAll("&quot;", "\""),
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),)
    );
  }
}