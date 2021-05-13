import 'dart:convert';

import 'package:des_plugin/des_plugin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List searchedList = [];
List topSongsList = [];
String kUrl = "",
    checker,
    image = "",
    title = "",
    album = "",
    artist = "",
    lyrics,
    has_320,
    rawkUrl;
String key = "38346591";
String decrypt = "";

Future<List> fetchSongsList(searchQuery) async {
  String searchUrl =
      "/api.php?app_version=5.18.3&api_version=4&readable_version=5.18.3&v=79&_format=json&query=" +
          searchQuery +
          "&__call=autocomplete.get";
  var res = await http.get(Uri.https("www.jiosaavn.com", searchUrl, {"Accept": "application/json"}));
  var resEdited = (res.body).split("-->");
  var getMain = json.decode(resEdited[1]);

  searchedList = getMain["songs"]["data"];
  for (int i = 0; i < searchedList.length; i++) {
    searchedList[i]['title'] = searchedList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");

    searchedList[i]['more_info']['singers'] = searchedList[i]['more_info']
    ['singers']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
  }
  return searchedList;
}

Future<List> topTrendingSongs() async {
  String topSongsUrl =
      "/api.php?__call=webapi.get&token=I3kvhipIy73uCJW60TJk1Q__&type=playlist&p=1&n=50&includeMetaTags=0&ctx=web6dot0&api_version=4&_format=json&_marker=0";
  var songsListJSON =
  await http.get(Uri.https("www.jiosaavn.com", topSongsUrl, {"Accept": "application/json"}));
  var songsList = json.decode(songsListJSON.body);
  topSongsList = songsList["list"];
  for (int i = 0; i < topSongsList.length; i++) {
    topSongsList[i]['title'] = topSongsList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
    topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"] =
        topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"]
            .toString()
            .replaceAll("&amp;", "&")
            .replaceAll("&#039;", "'")
            .replaceAll("&quot;", "\"");
    topSongsList[i]['image'] =
        topSongsList[i]['image'].toString().replaceAll("150x150", "500x500");
  }
  return topSongsList;
}
Future<List> topPunTrendingSongs() async {
  String topSongsUrl =
      "/api.php?__call=webapi.get&token=Vy34km3okmQ_&type=playlist&p=1&n=30&includeMetaTags=0&ctx=web6dot0&api_version=4&_format=json&_marker=0";
  var songsListJSON =
  await http.get(Uri.https("www.jiosaavn.com", topSongsUrl, {"Accept": "application/json"}));
  var songsList = json.decode(songsListJSON.body);
  topSongsList = songsList["list"];
  for (int i = 0; i < topSongsList.length; i++) {
    topSongsList[i]['title'] = topSongsList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
    topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"] =
        topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"]
            .toString()
            .replaceAll("&amp;", "&")
            .replaceAll("&#039;", "'")
            .replaceAll("&quot;", "\"");
    topSongsList[i]['image'] =
        topSongsList[i]['image'].toString().replaceAll("150x150", "500x500");
  }
  return topSongsList;
}
Future<List> topEngTrendingSongs() async {
  String topSongsUrl =
      "/api.php?__call=webapi.get&token=pm49jiq,CNs_&type=playlist&p=1&n=30&includeMetaTags=0&ctx=web6dot0&api_version=4&_format=json&_marker=0";
  var songsListJSON =
  await http.get(Uri.https("www.jiosaavn.com", topSongsUrl, {"Accept": "application/json"}));
  var songsList = json.decode(songsListJSON.body);
  topSongsList = songsList["list"];
  for (int i = 0; i < topSongsList.length; i++) {
    topSongsList[i]['title'] = topSongsList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
    topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"] =
        topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"]
            .toString()
            .replaceAll("&amp;", "&")
            .replaceAll("&#039;", "'")
            .replaceAll("&quot;", "\"");
    topSongsList[i]['image'] =
        topSongsList[i]['image'].toString().replaceAll("150x150", "500x500");
  }
  return topSongsList;
}
Future<List> topBollyTrendingSongs() async {
  String topSongsUrl =
      "/api.php?__call=webapi.get&token=BECHl0fsh08_&type=playlist&p=1&n=30&includeMetaTags=0&ctx=web6dot0&api_version=4&_format=json&_marker=0";
  var songsListJSON =
  await http.get(Uri.https("www.jiosaavn.com", topSongsUrl, {"Accept": "application/json"}));
  var songsList = json.decode(songsListJSON.body);
  topSongsList = songsList["list"];
  for (int i = 0; i < topSongsList.length; i++) {
    topSongsList[i]['title'] = topSongsList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
    topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"] =
        topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"]
            .toString()
            .replaceAll("&amp;", "&")
            .replaceAll("&#039;", "'")
            .replaceAll("&quot;", "\"");
    topSongsList[i]['image'] =
        topSongsList[i]['image'].toString().replaceAll("150x150", "500x500");
  }
  return topSongsList;
}

Future<List> topSongs() async {
  String topSongsUrl =
      "/api.php?__call=webapi.get&token=8MT-LQlP35c_&type=playlist&p=1&n=30&includeMetaTags=0&ctx=web6dot0&api_version=4&_format=json&_marker=0";
  var songsListJSON =
  await http.get(Uri.https("www.jiosaavn.com", topSongsUrl, {"Accept": "application/json"}));
  var songsList = json.decode(songsListJSON.body);
  topSongsList = songsList["list"];
  for (int i = 0; i < topSongsList.length; i++) {
    topSongsList[i]['title'] = topSongsList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
    topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"] =
        topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"]
            .toString()
            .replaceAll("&amp;", "&")
            .replaceAll("&#039;", "'")
            .replaceAll("&quot;", "\"");
    topSongsList[i]['image'] =
        topSongsList[i]['image'].toString().replaceAll("150x150", "500x500");
  }
  return topSongsList;
}

Future fetchSongDetails(songId) async {
  String songUrl =
      "/api.php?app_version=5.18.3&api_version=4&readable_version=5.18.3&v=79&_format=json&__call=song.getDetails&pids=" +
          songId;
  var res = await http.get(Uri.https("www.jiosaavn.com", songUrl, {"Accept": "application/json"}));
  var resEdited = (res.body).split("-->");
  var getMain = json.decode(resEdited[1]);

  title = (getMain[songId]["title"])
      .toString()
      .split("(")[0]
      .replaceAll("&amp;", "&")
      .replaceAll("&#039;", "'")
      .replaceAll("&quot;", "\"");
  image = (getMain[songId]["image"]).replaceAll("150x150", "500x500");
  album = (getMain[songId]["more_info"]["album"])
      .toString()
      .replaceAll("&quot;", "\"")
      .replaceAll("&#039;", "'")
      .replaceAll("&amp;", "&");

  try {
    artist =
    getMain[songId]['more_info']['artistMap']['primary_artists'][0]['name'];
  } catch (e) {
    artist = "-";
  }
  print(getMain[songId]["more_info"]["has_lyrics"]);
  if (getMain[songId]["more_info"]["has_lyrics"] == "true") {
    String lyricsUrl =
        "/api.php?__call=lyrics.getLyrics&lyrics_id=" +
            songId +
            "&ctx=web6dot0&api_version=4&_format=json";
    var lyricsRes =
    await http.get(Uri.https("www.jiosaavn.com", lyricsUrl, {"Accept": "application/json"}));
    var lyricsEdited = (lyricsRes.body).split("-->");
    var fetchedLyrics = json.decode(lyricsEdited[1]);
    lyrics = fetchedLyrics["lyrics"].toString().replaceAll("<br>", "\n");
  } else {
    lyrics = "null";
    String lyricsApiUrl =
        "/lyrics/" + artist + "/" + title;
    var lyricsApiRes =
    await http.get(Uri.https("musifydev.vercel.app", lyricsApiUrl, {"Accept": "application/json"}));
    var lyricsResponse = json.decode(lyricsApiRes.body);
    if (lyricsResponse['status'] == true && lyricsResponse['lyrics'] != null) {
      lyrics = lyricsResponse['lyrics'];
    }
  }

  has_320 = getMain[songId]["more_info"]["320kbps"];
  kUrl = await DesPlugin.decrypt(
      key, getMain[songId]["more_info"]["encrypted_media_url"]);

  rawkUrl = kUrl;

  final client = http.Client();
  final request = http.Request('HEAD', Uri.parse(kUrl))
    ..followRedirects = false;
  final response = await client.send(request);
  print(response);
  kUrl = (response.headers['location']);
  artist = (getMain[songId]["more_info"]["artistMap"]["primary_artists"][0]
  ["name"])
      .toString()
      .replaceAll("&quot;", "\"")
      .replaceAll("&#039;", "'")
      .replaceAll("&amp;", "&");
  debugPrint(kUrl);
}