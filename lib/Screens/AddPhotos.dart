import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loveafghan/Screens/Gender.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/util/color.dart';
import 'package:loveafghan/util/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as i;
// import 'package:google_ml_kit/google_ml_kit.dart';

class AddPhotos extends StatefulWidget {
  final Map<String, dynamic> userData;
  AddPhotos(this.userData);

  @override
  _AddPhotosState createState() => _AddPhotosState();
}

class _AddPhotosState extends State<AddPhotos> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String image_url = '';
  bool isImageUploaded = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future source(BuildContext context, bool isProfilePicture) async {
    print("Source CAlled");
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text(isProfilePicture
                  ? getTranslated(context, 'update_profile_picture')
                  : getTranslated(context, 'add_pictures')),
              content: Text(
                getTranslated(context, 'select_source'),
              ),
              insetAnimationCurve: Curves.decelerate,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.photo_camera,
                          size: 28,
                        ),
                        Text(
                          getTranslated(context, 'camera'),
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) {
                            getImage(
                                ImageSource.camera, context, isProfilePicture);
                            return Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ));
                          });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.photo_library,
                          size: 28,
                        ),
                        Text(
                          getTranslated(context, 'gallery'),
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            getImage(
                                ImageSource.gallery, context, isProfilePicture);
                            return Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ));
                          });
                    },
                  ),
                ),
              ]);
        });
  }

  Future getImage(ImageSource imageSource, context, isProfilePicture) async {
    print("getting Image");
    var image = await ImagePicker.pickImage(source: imageSource);
    if (image != null) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            title: 'Crop',
            rectX: 0.0,
            rectY: 0.0,
            rectWidth: 1024.0,
            rectHeight: 1024.0,
            minimumAspectRatio: 1.0,
            resetAspectRatioEnabled: false,
            aspectRatioLockEnabled: true,
          ));
      if (croppedFile != null) {
        // await detectFace(croppedFile).then((hasFace) async {
        //   if (hasFace) {
        //     await uploadFile(
        //         await compressimage(croppedFile), isProfilePicture);
        //   } else {
        //     CustomSnackbar.snackbar(
        //         "Please select photo containing your face!", _scaffoldKey);
        //   }
        // });

        //
        await uploadFile(await compressimage(croppedFile), isProfilePicture);
      }
    }
    Navigator.pop(context);
  }

  Future uploadFile(File image, isProfilePicture) async {
    isImageUploaded = false;
    final FirebaseUser user = await auth.currentUser();
    final String uid = user.uid;
    print("UID:" + uid);
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/$uid/${image.hashCode}.jpg');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    if (uploadTask.isInProgress == true) {
      print("Uploading...");
    }
    if (await uploadTask.onComplete != null) {
      storageReference.getDownloadURL().then((fileURL) async {
        setState(() {
          image_url = fileURL;
          print("Image Uploaded!");
          isImageUploaded = true;
        });
      });
    }
  }

  Future compressimage(File image) async {
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    i.Image imagefile = i.decodeImage(image.readAsBytesSync());
    final compressedImagefile = File('$path.jpg')
      ..writeAsBytesSync(i.encodeJpg(imagefile, quality: 80));
    // setState(() {
    print("Image Cropped");
    return compressedImagefile;
    // });
  }

  // Future<bool> detectFace(File file) async {
  //   final inputImage = InputImage.fromFile(file);
  //   final faceDetector = GoogleMlKit.vision.faceDetector();
  //   final List<Face> faces = await faceDetector.processImage(inputImage);
  //   faceDetector.close();
  //   return faces.isNotEmpty ? true : false;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(60),
        ),
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: IconButton(
          alignment: Alignment.centerRight,
          color: secondryColor,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Padding(
                    child: Text(
                      "Add your Image", // TODO : Translate this
                      style: TextStyle(fontSize: 40),
                    ),
                    padding: EdgeInsets.only(left: 50, top: 120),
                  ),
                ],
              ),
              Flexible(
                child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  alignment: Alignment.center,
                  child: Container(
                      width: 250,
                      height: 250,
                      margin: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: !isImageUploaded
                          ? IconButton(
                              color: primaryColor,
                              iconSize: 60,
                              icon: Icon(Icons.add_a_photo),
                              onPressed: () async {
                                await source(context, true);
                              },
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                image_url,
                                width: 250,
                                height: 250,
                                fit: BoxFit.fill,
                              ))),
                ),
              ),
              isImageUploaded
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        primaryColor.withOpacity(.5),
                                        primaryColor.withOpacity(.8),
                                        primaryColor,
                                        primaryColor
                                      ])),
                              height: MediaQuery.of(context).size.height * .065,
                              width: MediaQuery.of(context).size.width * .75,
                              child: Center(
                                  child: Text(
                                "CHANGE IMAGE",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                    fontWeight: FontWeight.bold),
                              ))),
                          onTap: () async {
                            await source(context, true);
                          },
                        ),
                      ),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              image_url.length > 0
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        primaryColor.withOpacity(.5),
                                        primaryColor.withOpacity(.8),
                                        primaryColor,
                                        primaryColor
                                      ])),
                              height: MediaQuery.of(context).size.height * .065,
                              width: MediaQuery.of(context).size.width * .75,
                              child: Center(
                                  child: Text(
                                getTranslated(context, 'continue'),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                    fontWeight: FontWeight.bold),
                              ))),
                          onTap: () {
                            widget.userData.addAll({
                              'Pictures': [
                                {"url": image_url, "approved": "false"}
                              ]
                            });
                            print(widget.userData);
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        Gender(widget.userData)));
                          },
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              height: MediaQuery.of(context).size.height * .065,
                              width: MediaQuery.of(context).size.width * .75,
                              child: Center(
                                  child: Text(
                                getTranslated(context, 'continue'),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: secondryColor,
                                    fontWeight: FontWeight.bold),
                              ))),
                          onTap: () {},
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
