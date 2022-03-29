import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterproject2/model/ad_helper.dart';
import 'package:flutterproject2/model/news_model.dart';
import 'package:flutterproject2/view/mainpage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class Newscontroller extends GetxController {
  late List<GamespotNews> gamespotnews;
  late List<Techradarnews> techradar;
  late InterstitialAd rewardad;
  Map bannermap = {};
  List alldata = [];
  int currentmax = 15;
  bool bol2 = false;
  bool videoisadready = false;
  bool bannerisready = false;
  int selectedindex = 0;
  ScrollController scrollController = Get.find();
  GetStorage box = GetStorage();
  @override
  void onInit() {
    // TODO: implement onInit
    Adhelper.getInterstitialad();

    news();

    if (box.read("darktheme") != null) {
      bol2 = box.read("darktheme");
    }
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        newdata();
      }
    });
    super.onInit();
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  void ads(index) {
    if (index % 6 == 0 && !bannermap.containsKey(index)) {
      bannermap[index] = Adhelper.getbanerad();
    } else if (bannermap.containsKey(index) && index % 6 == 0) {
      bannermap[index];
    }
  }

  void navigationbar(index) {
    selectedindex = index;
 

  }

  int indecator() {
    return currentmax == alldata.length ? 0 : 1;
  }

  void theme(val) {
    bol2 = val;
    box.write("darktheme", bol2);
    bol2 == false
        ? Get.changeTheme(ThemeData.dark())
        : Get.changeTheme(ThemeData.light());

    update();
  }

  void newdata() {
    if (currentmax == alldata.length) {
      Get.snackbar("Loading news", "no more data",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      currentmax = currentmax + 10;
      currentmax >= alldata.length ? currentmax = alldata.length : currentmax;

      update();
    }
  }

  void openurl(index) async {
    var url1 = alldata[index].link;
    if (await canLaunch(url1.toString())) {
      await launch(url1.toString(), forceWebView: true);
    } else {
      throw 'Could not launch $url1';
    }
  }

  Future news() async {
    await gettechradar();
    await getspotnews();

    alldata.addAll(gamespotnews);
    alldata.addAll(techradar);

    alldata.sort((a, b) => b.time.compareTo(a.time));
    update();
  }

  Future onrefresh() async {
    currentmax = 15;
    await gettechradar();
    await getspotnews();

    alldata.assignAll(gamespotnews);
    alldata.addAll(techradar);

    alldata.sort((a, b) => b.time.compareTo(a.time));
    update();
    Get.snackbar("Loading news", "Completed",
        snackPosition: SnackPosition.BOTTOM);
  }

  Future getspotnews() async {
    try {
      gamespotnews = [];
      Uri url = Uri.parse("https://www.gamespot.com/news");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var respnsebody = response.body;
        var document = parser.parse(respnsebody);
        var news = document
            .getElementsByClassName(
                "filter-results js-filter-results editorial thirds  river")[0]
            .getElementsByClassName(
                "card-item base-flexbox flexbox-align-center width-100 border-bottom-grayscale--thin")
            .forEach((element) {
          String time = element.children[1].children[0].children[2].children[0]
              .children[1].attributes["datetime"]
              .toString();
          String time2 = time.replaceAll("pm", "PM");
          String time3 = time2.replaceAll("am", "AM");

          gamespotnews.add(GamespotNews(
              title: element.children[1].children[0].children[1].text,
              link: "https://www.gamespot.com" +
                  element.children[1].children[0].children[1].attributes["href"]
                      .toString(),
              time: (DateFormat("EEEE, MMM dd, yyyy hh:mmaaa").parse(time3)),
              website: 'gamespot'));
        });
      }
    } catch (exception) {
      print(exception);
    } finally {}
  }

  Future gettechradar() async {
    try {
      techradar = [];
      Uri url = Uri.parse("https://www.techradar.com/gaming/news");

      var response = await http.get(url);

      if (response.statusCode == 200) {
        var respnsebody = response.body;
        var document = parser.parse(respnsebody);
        var news = document
            .getElementsByClassName("listingResults news")[0]
            .getElementsByClassName("listingResult small")
            .forEach((element) {
          String time = element.children[0].children[0].children[1].children[0]
              .children[1].children[1].attributes["datetime"]
              .toString();
          techradar.add(Techradarnews(
              title: element.children[0].children[0].children[1].children[0]
                  .children[0].text
                  .toString(),
              link: element.children[0].attributes["href"].toString(),
              time: DateTime.parse(time),
              website: 'techradar'));
        });
      }
      gettechradar2();
    } catch (exception) {
      print(exception);
    } finally {}
  }

  Future gettechradar2() async {
    try {
      Uri url = Uri.parse("https://www.techradar.com/gaming/news/page/2");

      var response = await http.get(url);

      if (response.statusCode == 200) {
        var respnsebody = response.body;
        var document = parser.parse(respnsebody);
        var news = document
            .getElementsByClassName("listingResults news")[0]
            .getElementsByClassName("listingResult small")
            .forEach((element) {
          String time = element.children[0].children[0].children[1].children[0]
              .children[1].children[1].attributes["datetime"]
              .toString();
          techradar.add(Techradarnews(
              title: element.children[0].children[0].children[1].children[0]
                  .children[0].text
                  .toString(),
              link: element.children[0].attributes["href"].toString(),
              time: DateTime.parse(time),
              website: 'techradar'));
        });
      }
      gettechradar3();
    } catch (exception) {
      print(exception);
    } finally {}
  }

  Future gettechradar3() async {
    try {
      Uri url = Uri.parse("https://www.techradar.com/gaming/news/page/6");

      var response = await http.get(url);

      if (response.statusCode == 200) {
        var respnsebody = response.body;
        var document = parser.parse(respnsebody);
        var news = document
            .getElementsByClassName("listingResults news")[0]
            .getElementsByClassName("listingResult small")
            .forEach((element) {
          String time = element.children[0].children[0].children[1].children[0]
              .children[1].children[1].attributes["datetime"]
              .toString();
          techradar.add(Techradarnews(
              title: element.children[0].children[0].children[1].children[0]
                  .children[0].text
                  .toString(),
              link: element.children[0].attributes["href"].toString(),
              time: DateTime.parse(time),
              website: 'techradar'));
        });
      }
    } catch (exception) {
      print(exception);
    } finally {}
  }
}
