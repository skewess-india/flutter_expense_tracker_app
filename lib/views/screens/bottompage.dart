import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/controllers/bottomsheet_controller.dart';
import 'package:flutter_expense_tracker_app/views/screens/home_screen.dart';
import 'package:flutter_expense_tracker_app/views/screens/pic_upload%20_screen.dart';
import 'package:get/get.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  BottomSheetController controller = Get.put(BottomSheetController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomSheetController>(builder: (controller) {
      return Scaffold(
          // extendBody for floating bar get better perfomance
          // extendBody: true,
          backgroundColor: Colors.white,
          body: controller.bottomindex == 0
              ? HomeScreen()
              : controller.bottomindex == 1
                  ? PicUploadScreen()
                  : Center(child: Text("welcome")),
          bottomNavigationBar: _buildOriginDesign());
    });
  }

  Widget _buildOriginDesign() {
    return CustomNavigationBar(
      iconSize: 30.0,
      selectedColor: Colors.white,
      // strokeColor: Colors.white,
      unSelectedColor: Colors.black,
      backgroundColor: Colors.blue,
      items: [
        CustomNavigationBarItem(
          icon: Icon(Icons.currency_rupee_outlined),
        ),
        CustomNavigationBarItem(
          icon: Icon(Icons.home),
        ),
        CustomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline),
        ),
      ],
      currentIndex: controller.bottomindex,
      onTap: (index) {
        controller.bottomindex = index;
        controller.update();
      },
    );
  }
}
