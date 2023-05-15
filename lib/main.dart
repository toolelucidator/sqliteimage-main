import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'convert_utility.dart';
import 'dbManager.dart';
import 'photo.dart';
import 'dart:io';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SaveImage(),
    );
  }
}

class SaveImage extends StatefulWidget {
  const SaveImage({Key? key}) : super(key: key);

  @override
  State<SaveImage> createState() => _SaveImageState();
}

class _SaveImageState extends State<SaveImage> {
  late List<Photo> photos;
  late dbManager dbmanager;
  late Future<File> imageFile;
  late Image image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbmanager = dbManager();
    photos = [];
    refreshImages();
  }

  refreshImages() {
    dbmanager.getPhotos().then((images) {
      setState(() {
        photos.clear();
        photos.addAll(images);
      });
    });
  }

  pickImageFromGallery() {
    ImagePicker imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.gallery).then((imgFile) async {
      Uint8List? imageBytes = await imgFile?.readAsBytes();
      String imgString = Utility.base64String(imageBytes!);
      Photo photo = Photo(null, imgString);
      dbmanager.save(photo);
      refreshImages();
    });
  }

  gridView() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: photos.map((photo) {
          return Utility.ImageFromBase64String(photo.photo_name!);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SQLite Image"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              pickImageFromGallery();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: gridView(),
            )
          ],
        ),
      ),
    );
  }
}
