// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

import 'package:ocr_document_scanner/preview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isCamera = false;
  File? _image;
  final picker = ImagePicker();
  List<String> _resultText = [];
  // bool isAadhar = true;

  @override
  void initState() {
    super.initState();
    // Show the alert dialog when the app opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAlertDialog();
    });
  }

  //Function to get image from gallery or camera.
  Future<void> getImage(bool isCamera) async {
    final pickedImage = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        _resultText = []; // Clear previous recognized text
      });
      await recognizedText();
    } else {
      setState(() {
        _image = null; // Clear the image if nothing is selected
        _resultText = []; // Clear the text as well
      });
    }
  }

  //Function to scan the image selected and extract the text.
  Future<void> recognizedText() async {
    if (_image == null) return;
    //Shows loading animation till the image processing is done
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    List<String> scannedText = recognizedText.text.split("\n");

    //RegExp for aadhar no. pattern.

    //Aadhar No. matching or identifying
    // for (var e in scannedText) {
    //   if (aadharRegex.hasMatch(e)) {
    //     scannedText[scannedText.indexOf(e)] = 'Aadhar No.: $e';
    //   }
    // }

    // for (var e in scannedText) {
    //   Match? match = genderRegex.firstMatch(e);

    //   if (match != null) {
    //     scannedText[scannedText.indexOf(e)] = 'Gender: ${match.group(0)}';
    //   }
    // }

    //     caseSensitive: false);
    // for (var e in scannedText) {
    //   Match? match = dobRegex.firstMatch(e);
    //   if (match != null) {
    //     scannedText[scannedText.indexOf(e)] = "${match.group(1)}";
    //   }
    // }

    // for (var e in scannedText) {
    //   if (nameRegex.hasMatch(e)) {
    //     scannedText[scannedText.indexOf(e)] = "Name: $e";
    //   }
    // }

    //Regular EXpressions
    RegExp nameRegex =
        RegExp(r"^[A-Z][a-zA-Z'’\-.\s]+(?:\s+[A-Z][a-zA-Z'’\-.\s]+)*$");
    RegExp panDobRegex = RegExp(r'^(?:(\d{2}\/\d{2}\/\d{4})|(\d{4}))$');
    RegExp aadharDobRegex = RegExp(
        r'(?:year of birth|dob)\s*[:\-]?\s*(\d{2}\/\d{2}\/\d{4}|\d{4})',
        caseSensitive: false);
    RegExp genderRegex =
        RegExp(r'\b(?:male|female|other)\b', caseSensitive: false);
    RegExp aadharRegex = RegExp(r'^\d{4} \d{4} \d{4}$');
    RegExp panRegex = RegExp(r'^[A-Z]{5}\d{4}[A-Z]$');

    List<String> validInputs = [];

    for (String e in scannedText) {
      if (aadharRegex.hasMatch(e)) {
        for (String e in scannedText) {
          if (nameRegex.hasMatch(e)) {
            validInputs.add(e);
          } else if (aadharDobRegex.firstMatch(e) != null) {
            validInputs.add("${aadharDobRegex.firstMatch(e)!.group(1)}");
          } else if (genderRegex.firstMatch(e) != null) {
            validInputs.add("${genderRegex.firstMatch(e)!.group(0)}");
          } else if (aadharRegex.hasMatch(e)) {
            validInputs.add(e);
          }
        }
      } else if (panRegex.hasMatch(e)) {
        for (String e in scannedText) {
          if (e.contains("GOVT.") ||
              e.contains("Name") ||
              e.contains("Signature") ||
              e.contains("Birth") ||
              e.contains("Permanent")) {
            // DO nothing
          } else if (nameRegex.hasMatch(e)) {
            validInputs.add(e);
          } else if (panDobRegex.firstMatch(e) != null) {
            validInputs.add("${panDobRegex.firstMatch(e)!.group(1)}");
          } else if (panRegex.hasMatch(e)) {
            validInputs.add(e);
          }
        }
      }
    }

    //Closing the textRecognizer
    textRecognizer.close();

    setState(() {
      _resultText = validInputs;
    });

    Navigator.of(context).pop();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Previews(_resultText)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Document Scanner",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () => getImage(false),
                child: Container(
                  height: 200,
                  width: 300,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                  child: Card(
                    elevation: 10,
                    color: Colors.blueAccent,
                    child: Container(
                      height: 200,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_back_outlined,
                            color: Colors.white,
                            size: 50,
                          ),
                          Text(
                            "Gallery",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => getImage(true),
                child: SizedBox(
                  height: 200,
                  width: 300,
                  child: Card(
                    elevation: 10,
                    color: Colors.blueAccent,
                    child: Container(
                      height: 200,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 50,
                          ),
                          Text(
                            "Camera",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Function to display instructions for better results
  void _showAlertDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Welcome!!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please follow these instructions for better results.'),
                Text(
                    '1) If using camera for better results capture image in portrait.'),
                Text("2) Greyscale images will yield better results."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Approve',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
