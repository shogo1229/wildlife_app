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
  final cameras = await availableCameras(); // 使用可能なカメラのリストを取得
  final firstCamera = cameras.first; // 最初のカメラを選択

  runApp(
    MaterialApp(
      home: CameraApp(camera: firstCamera), // アプリを起動
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
  late CameraController _controller; // カメラコントローラー
  LocationData? _locationData; // 緯度と経度を格納する変数
  bool _isPhotoPreviewVisible = false;
  XFile? _capturedPhoto;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
        widget.camera, ResolutionPreset.medium); // カメラコントローラーを初期化
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {}); // カメラが初期化されたらUIを更新
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // カメラコントローラーを破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPhotoPreviewVisible) {
      return PhotoPreviewScreen(
        photo: _capturedPhoto!,
        onRetake: () {
          setState(() {
            _isPhotoPreviewVisible = false;
            _capturedPhoto = null;
          });
        },
        onSave: () {
          _savePhoto(); // 写真を保存する処理を実装
        },
      );
    }

    if (!_controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Camera App')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CameraPreview(_controller),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _locationData != null
                  ? 'Latitude: ${_locationData!.latitude}, Longitude: ${_locationData!.longitude}'
                  : 'Location information not available',
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
      return;
    }

    final XFile file = await _controller.takePicture();

    final LocationData? locationData = await _getLocation();

    setState(() {
      _locationData = locationData;
      _capturedPhoto = file;
      _isPhotoPreviewVisible = true;
    });
  }

  Future<LocationData?> _getLocation() async {
    final location = Location();
    try {
      print('位置情報の取得に成功しました');
      return await location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  void _savePhoto() async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference storageRef =
        storage.ref().child('photos').child('photo.jpg');

    try {
      final UploadTask uploadTask =
          storageRef.putFile(File(_capturedPhoto!.path));
      await uploadTask.whenComplete(() async {
        final String photoURL = await storageRef.getDownloadURL();
        print(photoURL);
        final CollectionReference photos =
            FirebaseFirestore.instance.collection('photos');
        await photos.add({
          'url': photoURL,
          'latitude': _locationData?.latitude,
          'longitude': _locationData?.longitude,
        });

        // 保存成功時の処理
        _showSnackBar('Photo saved successfully');
        _resetState();
      });
    } catch (e) {
      // エラーが発生した場合の処理
      print('Error saving photo: $e');
      _showErrorDialog();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ));
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save the photo. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetState();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetState() {
    setState(() {
      _locationData = null;
      _capturedPhoto = null;
      _isPhotoPreviewVisible = false;
    });
  }
}

class PhotoPreviewScreen extends StatefulWidget {
  final XFile photo;
  final Function onRetake;
  final Function onSave;

  PhotoPreviewScreen({
    Key? key,
    required this.photo,
    required this.onRetake,
    required this.onSave,
  }) : super(key: key);

  @override
  _PhotoPreviewScreenState createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Preview')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(File(widget.photo.path)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  widget.onRetake();
                },
                child: Text('Retake'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  widget.onSave();
                },
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
