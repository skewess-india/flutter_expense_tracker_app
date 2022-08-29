import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_save/image_save.dart';

import 'package:nanoid/nanoid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';

import '../../controllers/controller.dart';

class SnapArea extends StatefulWidget {
  // final String title;
  // final String size;
  SnapArea({
    Key? key,
  }) : super(key: key);

  @override
  _SnapAreaState createState() => _SnapAreaState();
}

class _SnapAreaState extends State<SnapArea> with WidgetsBindingObserver {
  ScreenshotController screenshotController = ScreenshotController();
  var nanid;
  final picker = ImagePicker();
  List<File> listOfImages = [];
  final pdf = pw.Document();
  File? pathh;
  Uint8List? byte;

  final ListController controller = Get.put(ListController());

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    setNanoId();
    super.initState();
  }

  setNanoId() {
    setState(() {
      nanid = nanoid(10);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return GetBuilder<ListController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          // title: Text(
          //   widget.title,
          //   style: TextStyle(),
          // ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(children: [
          Column(
            children: [
              controller.listOfImages.isNotEmpty
                  ? Expanded(
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 2 / 2.8,
                            crossAxisCount: 1,
                          ),
                          itemCount: controller.listOfImages.length,
                          itemBuilder: (BuildContext ctx, index) {
                            return SizedBox(
                              height: size.height * .4,
                              width: size.width,
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                            height: size.height * .54,
                                            // width: size.width * .4,
                                            child: Image.file(
                                              controller.listOfImages[index],
                                              fit: BoxFit.fill,
                                            )),
                                      ),
                                      Align(
                                          alignment: Alignment.topRight,
                                          child: CircleAvatar(
                                            child: Text((index + 1).toString()),
                                            maxRadius: 15,
                                          )),
                                    ],
                                  ),
                                  Align(
                                      alignment: Alignment.bottomRight,
                                      child: InkWell(
                                        onTap: () {
                                          print(index);
                                          controller.listOfImages
                                              .removeAt(index);

                                          listOfImages.remove(index);
                                          print(controller.listOfImages);
                                          print(listOfImages);
                                          controller.update();
                                        },
                                        child: const CircleAvatar(
                                          child: Icon(Icons.delete),
                                          maxRadius: 15,
                                        ),
                                      ))
                                ],
                              ),
                            );
                          }),
                    )
                  : const Expanded(
                      child: Center(
                        child: Text(
                          'Atleast one snap to upload.',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       primary: Colors.white,
                  //       shape: RoundedRectangleBorder(
                  //         side: BorderSide(color: Colors.blue),
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //     ),
                  //     onPressed: (){},
                  //     child: const Text(
                  //       "Take a Snap",
                  //       style: TextStyle(color: Colors.blue),
                  //     )),
                  Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: controller.listOfImages.isNotEmpty
                            ? Colors.white
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: controller.listOfImages.isEmpty
                          ? null
                          : () async {
                              if (listOfImages.isNotEmpty) {
                                await createPDF();
                                await savePDF();
                                // listOfImages.clear();
                                controller.listOfImages.clear();

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("PDF Upload Successfully"),
                                ));
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      "Atleast need one Image for usage!!!"),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            },
                      child: const Text(
                        "Upload to Drive",
                        style: TextStyle(color: Colors.blue),
                      ))),
                ],
              ),
            ],
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Get.to(SnapArea());
            takepic();
          },
          child: Icon(Icons.add_a_photo),
          backgroundColor: Colors.blue,
        ),
      );
    });
  }

  /// To display loader with loading text
  void showLoader() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(seconds: 2),
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, animation, secondaryAnimation) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  createPDF() {
    // controller.listOfImages.asMap().forEach((index, value) {
    //   print(value.path);
    //   final image = pw.MemoryImage(value.readAsBytesSync());

    //   int a = controller.listOfImages.indexOf(value);

    //   pdf.addPage(pw.Page(
    //       pageFormat: PdfPageFormat.a4,
    //       build: (pw.Context contex) {
    //         return pw.Column(children: [
    //           pw.Row(children: [
    //             pw.Spacer(),
    //             pw.Text("${index++}.toString()",
    //                 style: pw.TextStyle(
    //                     fontWeight: pw.FontWeight.bold, fontSize: 18))
    //           ]),
    //           pw.Image(image)
    //         ]);
    //       }));
    // });
    for (var img in controller.listOfImages) {
      print(img.path);
      final image = pw.MemoryImage(img.readAsBytesSync());

      List i = [];

      controller.listOfImages.forEach((e) {
        i.add(e.path);
      });

      print(i);

      int a = i.indexOf(img.path);
      print(a);
      int b = a + 1;
      print(b);
      print("b");

      i.clear();

      // pdf.addPage(pw.Page(
      //     pageFormat: PdfPageFormat.a4,
      //     build: (pw.Context contex) {
      //       return pw.Column(children: [pw.Image(image)]);
      //     }));
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context contex) {
            return pw.Column(children: [
              pw.Row(children: [
                pw.Spacer(),
                pw.Text(b.toString(),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 18))
              ]),
              pw.Container(
                  height: Get.height * 0.7,
                  width: Get.width * 0.7,
                  child: pw.Image(image)),
            ]);
          }));
    }
    // await savePDF();
  }

  savePDF() async {
    setState(() {
      nanid = nanoid(15);
    });
    try {
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/$nanid.pdf');
      await file.writeAsBytes(await pdf.save());
      print(file.path);
      setState(() {
        pathh = File(file.path);
      });
      print('success');
    } catch (e) {
      print("Failure to Save PDF");
    }
  }

  takepic() async {
    {
      var nanid = nanoid(10);
      final XFile? photo =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: photo!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             const ExampleCameraOverlay()));
      return showDialog(
        context: context,
        barrierColor: Colors.black,
        builder: (context) {
          return AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              backgroundColor: Colors.black,
              title: const Text('Capture',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center),
              actions: [
                OutlinedButton(
                    onPressed: () {
                      screenshotController
                          .capture(delay: const Duration(milliseconds: 10))
                          .then((Uint8List? image) async {
                        bool? success = await ImageSave.saveImage(
                            image, "$nanid.png",
                            albumName: "stuart");
                        print("Success");

                        setState(() {
                          pathh = File(
                              "/storage/emulated/0/Pictures/stuart/$nanid.png");
                          listOfImages.add(pathh!);
                          controller.addFile(pathh!);

                          print(listOfImages);
                          byte;
                        });

                        Future.delayed(Duration(seconds: 3), () {
                          Navigator.pop(context);
                        });
                      });
                    },
                    child: const Icon(Icons.save))
              ],
              content: Screenshot(
                controller: screenshotController,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.grey,
                    BlendMode.saturation,
                  ),
                  child: SizedBox(
                      width: Get.width * 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          alignment: FractionalOffset.center,
                          image: FileImage(
                            File(croppedFile!.path),
                          ),
                        )),
                      )),
                ),
              ));
        },
      );
    }
  }
}
