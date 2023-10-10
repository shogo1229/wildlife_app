import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:location/location.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:io';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      home: CameraApp(camera: firstCamera),
    ),
  );
}

class CameraApp extends StatefulWidget {
  final CameraDescription camera;

  CameraApp({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  LocationData? _locationData; // 緯度と経度を格納する変数

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container(); // カメラが初期化されていない場合は、空のコンテナを表示
    }
    return Scaffold(
      appBar: AppBar(title: Text('Camera App')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CameraPreview(_controller), // カメラのプレビューを表示
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _locationData != null
                  ? '緯度: ${_locationData!.latitude}, 経度: ${_locationData!.longitude}'
                  : '位置情報なし',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera),
      ),
    );
  }

  void _takePicture() async {
    if (!_controller.value.isInitialized) {
      return; // カメラが初期化されていない場合は何もしない
    }

    final XFile file = await _controller.takePicture(); // カメラから写真を撮影

    final LocationData? locationData = await _getLocation(); // 位置情報を取得

    setState(() {
      _locationData = locationData; // 緯度と経度をセット
    });

    _uploadToFirebase(file, locationData); // Firebaseに写真をアップロード
  }
}

Future<LocationData?> _getLocation() async {
  final location = Location();
  try {
    return await location.getLocation(); // 位置情報を非同期で取得
  } catch (e) {
    //print('Error getting location: $e'); // エラーが発生した場合はエラーメッセージを表示
    return null;
  }
}

void _uploadToFirebase(XFile file, LocationData? locationData) async {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final Reference storageRef = storage.ref().child('photos').child('photo.jpg');

  final UploadTask uploadTask = storageRef.putFile(File(file.path)); // Firebase Storageに写真をアップロード
  await uploadTask.whenComplete(() async {
    final String photoURL = await storageRef.getDownloadURL(); // アップロードが完了したら写真のダウンロードURLを取得
    print(photoURL);
    final CollectionReference photos = FirebaseFirestore.instance.collection('photos');
    await photos.add({
      'url': photoURL, // Firestoreに写真のURLを保存
      'latitude': locationData?.latitude, // Firestoreに位置情報を保存
      'longitude': locationData?.longitude,
    });
  });
}
