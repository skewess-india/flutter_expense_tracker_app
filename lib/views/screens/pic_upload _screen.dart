import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class PicUploadScreen extends StatelessWidget {
  const PicUploadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true,
      body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Take a Snap"), Icon(Icons.upload)])),
    );
  }
}
