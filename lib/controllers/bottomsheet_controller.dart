import 'package:get/get.dart';

class BottomSheetController extends GetxController {
  int bottomindex = 0;
  changesindex(index) {
    bottomindex = index;
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}
