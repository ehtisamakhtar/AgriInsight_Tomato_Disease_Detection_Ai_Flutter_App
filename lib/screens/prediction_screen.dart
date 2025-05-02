import 'package:agriinsight_ai/screens/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'dart:io';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String prediction = '';
  String accuracy = '';
  bool isLoading = false;

  final ImagePicker picker = ImagePicker();
  File? filePath;

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> requestPermissions() async {
    bool cameraGranted = await Permission.camera.isGranted;
    bool storageGranted = await Permission.storage.isGranted;

    if (!cameraGranted || !storageGranted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage,
        Permission.photos,
      ].request();

      cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
      storageGranted = statuses[Permission.storage]?.isGranted ?? false;

      if (!cameraGranted || !storageGranted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Permissions Denied'),
            content: Text('Camera and storage permissions are required.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                },
                child: Text('Open Settings'),
              ),
            ],
          ),
        );
        return false;
      }
    }

    return true;
  }

  pickImage() async {
    bool granted = await requestPermissions();
    if (!granted) return;

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      filePath = File(image.path);
      prediction = '';
      accuracy = '';
    });
  }

  takePhoto() async {
    bool granted = await requestPermissions();
    if (!granted) return;

    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    setState(() {
      filePath = File(photo.path);
      prediction = '';
      accuracy = '';
    });
  }

  Future<void> tfLiteSetup() async {
    await Tflite.loadModel(
      model: "assets/disease_model.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> runModel() async {
    if (filePath == null) {
      Fluttertoast.showToast(msg: "Pick an image first.");
      return;
    }

    setState(() => isLoading = true);

    var recognitions = await Tflite.runModelOnImage(
      path: filePath!.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.4,
      asynch: true,
    );

    setState(() => isLoading = false);

    if (recognitions == null || recognitions.isEmpty) {
      Fluttertoast.showToast(msg: "Couldn't recognize the image.");
      return;
    }

    setState(() {
      prediction = recognitions[0]['label'];
      accuracy = (recognitions[0]['confidence'] * 100).toStringAsFixed(2) + "%";
    });
  }

  @override
  void initState() {
    super.initState();
    tfLiteSetup();
    filePath = null;
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Disease Detection",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: Icon(Icons.cleaning_services, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                filePath = null;
                prediction = '';
                accuracy = '';
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Signin()));
        },
        child: Icon(Icons.logout),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              filePath == null
                  ? Image.asset('assets/blank.png', height: 256, width: 256)
                  : Image.file(filePath!, height: 256, width: 256),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: pickImage,
                    child: Text('Select from Gallery'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: takePhoto,
                    child: Text('Take Picture'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: MaterialButton(
                  onPressed: runModel,
                  height: 50,
                  color: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          "Predict",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              SizedBox(height: 30),
              if (prediction.isNotEmpty)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Text("Prediction: $prediction",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Confidence: $accuracy",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
