import 'package:agriinsight_ai/screens/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'dart:io';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  String prediction = '';
  String accuracy = '';

  final ImagePicker picker = ImagePicker();
  File? filePath;

  //TODO: Define functions to upload an image

  pickImage() async{
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if(image == null) return;
    var imgMap = File(image.path);

    setState(() {
      filePath = imgMap;
    });
  }

  takePhoto() async{
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if(photo == null) return;
    var imgMap = File(photo.path);

    setState(() {
      filePath = imgMap;
    });
  }

  //TODO: Function to initialize the model
  Future<void> tfLiteSetup() async{
    String? res = await Tflite.loadModel(
        model: "assets/disease_model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false
    );
  }

  //TODO: Function to run the model on the image
  Future<void> runModel() async{

    if(filePath == null) {
      // print("Pick an image");
      Fluttertoast.showToast(
        msg: "Pick an image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,);

      return;
    }
    var recognitions = await Tflite.runModelOnImage(
        path: filePath!.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.4,
        asynch: true
    );

    if(recognitions == null){
      // print("Can't recognize the image");
      Fluttertoast.showToast(
        msg: "Can't recognize the image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,);

      return;
    }
    print(recognitions);

    setState(() {
      prediction = recognitions[0]['label'];
      accuracy = recognitions[0]['confidence'].toString();
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
      appBar: AppBar(title: Text('Image Classification',
        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          centerTitle: true,
          backgroundColor: const Color(0xFF2E7D32),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.cleaning_services,color: Colors.black,size: 20,),
              onPressed: () {
                setState(() {
                  filePath = null;
                  prediction = '';
                  accuracy = '';
                });
              },
            ),
          ]
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signin()));}, child: Icon(Icons.logout),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //TODO: Initialize the image widget
          (filePath== null)?Image(image: AssetImage('assets/blank.png'),height: 256,width: 256,)
              :Image.file(filePath!,height: 256,width: 256),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){
                //TODO: Upload image from gallery
                pickImage();
              }, child: Text('Select from Gallery')),
              SizedBox(width: 10,),
              ElevatedButton(onPressed: (){
                //TODO: Upload image from camera
                takePhoto();
              }, child: Text('Take Picture'))
            ],
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: MaterialButton(
              onPressed: (){
                runModel();
              },
              height: 50,
              color: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Text(
                  "Predict",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Column(
            children: [
              Text('Prediction: $prediction'),
              Text('Confidence: $accuracy'),
            ],
          ),
        ],
      ),
    );
  }
}
