import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ));

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File pickedImage;
  bool isImageLoaded = false;

  List _result;

  String _confidence = "";
  String _name = "";

  getImageFromGallery() async {
    var tempStore = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = File(tempStore.path);
      isImageLoaded = true;
      applyModelOnImage(pickedImage);
    });
  }

  loadModer() async {
    var resultant = await Tflite.loadModel(
        labels: "assets/pokemons.txt", model: "assets/pokemon_cnn3.tflite");
    //model: "assets/pokedex.tflite");
    //model: "assets/pokemon_cnn.tflite");
    print("resultant afeter loading model: $resultant");
  }

  @override
  void initState() {
    super.initState();
    loadModer().then((val) {
      setState(() {});
    });
  }

  applyModelOnImage(File file) async {
    var res = await Tflite.runModelOnImage(
        path: file.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _result = res;
      print(_result);
      print(_result[0]);
      String str = _result[0]['label'];
      _name = str.substring(0);
      _confidence = _result != null
          ? (_result[0]['confidence'] * 100.0).toString().substring(0, 3) + "%"
          : "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokedex'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 30),
            isImageLoaded
                ? Center(
                    child: Container(
                      height: 350,
                      width: 350,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(File(pickedImage.path)),
                              fit: BoxFit.contain)),
                    ),
                  )
                : Container(),
            SizedBox(
              height: 30,
            ),
            Text('Name: $_name\nConfidence: $_confidence')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImageFromGallery();
        },
        child: Icon(
          Icons.photo_album,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
