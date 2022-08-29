import 'dart:io';

// import 'package:camera/camera.dart';
import 'package:get/get.dart';

class ListController extends GetxController {
  List<File> listOfImages = <File>[].obs;

  addFile(File a) {
    listOfImages.add(a);
    update();
  }
}
