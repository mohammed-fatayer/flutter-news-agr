import 'package:flutter/cupertino.dart';
import 'package:flutterproject2/controller/newscontroller.dart';

import 'package:get/get.dart';

class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() =>Newscontroller());
    Get.lazyPut(() =>ScrollController());
  }
}
