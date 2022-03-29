import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterproject2/model/ad_helper.dart';

import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controller/newscontroller.dart';
import 'package:timeago/timeago.dart' as timeago;

ScrollController scrollController = Get.find();
Newscontroller controller = Get.find();

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);

  int selectedindex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Game News"),
          centerTitle: true,
        ),
        // bottomNavigationBar: BottomNavigationBar(
        //     currentIndex: selectedindex,
        //     onTap: (index) {
        //       setState(() {
        //         selectedindex = index;
        //       });
        //     },
        //     backgroundColor: Colors.white24,
        //     items: const [
        //       BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: "1"),
        //       BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: "2"),
        //       BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: "3"),
        //     ]),
        drawer: Drawer(
          child: GetBuilder<Newscontroller>(
            builder: (controller) => Column(
              children: [
                const UserAccountsDrawerHeader(
                    accountName: Text(""),
                    accountEmail: Text(""),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: AssetImage("images/lan.png"),
                    )),
                SwitchListTile(
                    value: controller.bol2,
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: const Text("Theme"),
                    subtitle: Text(controller.bol2 == false ? "dark" : "light"),
                    secondary: const Icon(Icons.flag),
                    onChanged: (val) {
                      controller.theme(val);
                    }),
                // ListTile(
                //     title: const Text("home page"),
                //     leading: const Icon(Icons.home),
                //     onTap: () {}),
                ListTile(
                    title: const Text("about app"),
                    leading: const Icon(Icons.help_center),
                    onTap: () {
                      Get.toNamed("/about");
                    }),
                // ListTile(
                //     title: const Text("setting"),
                //     leading: const Icon(Icons.settings),
                //     onTap: () {}),
                // ListTile(
                //     title: const Text("logout"),
                //     leading: const Icon(Icons.logout),
                //     onTap: () {}),
              ],
            ),
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     showSearch(context: context, delegate: DataSearch());
        //   },
        //   child: const Icon(Icons.search),
        // ),
        body: GetBuilder<Newscontroller>(
            builder: ((controller) => controller.alldata.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () {
                      return controller.onrefresh();
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.currentmax + controller.indecator(),
                      itemBuilder: (BuildContext context, int index) {
                        controller.ads(index);

                        return index == controller.currentmax
                            ? const CupertinoActivityIndicator()
                            : InkWell(
                                onTap: () {
                                  int max = Random().nextInt(2);
                                  if (controller.videoisadready && max == 1) {
                                    controller.rewardad.show();
                                    controller.rewardad
                                            .fullScreenContentCallback =
                                        FullScreenContentCallback(
                                            onAdDismissedFullScreenContent:
                                                (ad) {
                                      controller.rewardad.dispose();
                                      controller.videoisadready = false;
                                      Adhelper.getInterstitialad();
                                      controller.openurl(index);
                                    });
                                  } else {
                                    controller.openurl(index);
                                  }
                                },
                                child: Column(
                                  children: [
                                    // ===========================
                                    if (index % 6 == 0 &&
                                        controller.bannerisready)
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            height: 60,
                                            child: AdWidget(
                                              ad: controller.bannerisready
                                                  ? controller.bannermap[index]
                                                  : const Text(""),
                                            ),
                                          ),
                                          const Divider(
                                            thickness: 1,
                                            indent: 7,
                                            endIndent: 5,
                                          ),
                                        ],
                                      ),
                                    //  =================================
                                    Container(
                                      width: double.infinity,
                                      height: 100,
                                      margin: const EdgeInsets.all(2),
                                      padding: const EdgeInsets.all(15),
                                      child: ListTile(
                                        title: Text(
                                            controller.alldata[index].title,
                                            style: TextStyle(
                                              color: Colors.red[900],
                                              fontWeight: FontWeight.bold,
                                            )),
                                        subtitle: Text(
                                          timeago.format(controller
                                                  .alldata[index].time)+" by "+controller.alldata[index].website
                                        ),
                                        trailing: Text("${index + 1}"),
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 1,
                                      indent: 7,
                                      endIndent: 5,
                                    ),
                                  ],
                                ),
                              );
                      },
                    ),
                  ))));
  }
}
