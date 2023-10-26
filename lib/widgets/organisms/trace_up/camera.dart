import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:location/location.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/photo_preview_screen.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  LocationData? _locationData;
  bool _isPhotoPreviewVisible = false;
  XFile? _capturedPhoto;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.medium);
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
    if (_isPhotoPreviewVisible) {
      return PhotoPreviewScreen(
        photo: _capturedPhoto!,
        onRetake: _retakePhoto,
        onSave: _savePhoto,
        locationData: _locationData,
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
      await _controller.initialize();
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

  void _retakePhoto() {
    setState(() {
      _isPhotoPreviewVisible = false;
      _capturedPhoto = null;
    });
  }

  void _savePhoto() async {
    final FirebaseStorage storage = FirebaseStorage.instance;

    final String timestamp = DateTime.now().toIso8601String();
    final String fileName = 'photo_$timestamp.jpg';

    final Reference storageRef = storage.ref().child('photos').child(fileName);

    try {
      final UploadTask uploadTask =
          storageRef.putFile(File(_capturedPhoto!.path));
      await uploadTask.whenComplete(() async {
        final String photoURL = await storageRef.getDownloadURL();
        print(photoURL);
        FirebaseFirestore.instance.collection('wildlife_trace').add({
          'url': photoURL,
          'latitude': _locationData?.latitude,
          'longitude': _locationData?.longitude,
          'timestamp': timestamp,
        });
        _showSnackBar('Photo saved successfully');
        _resetState();
      });
    } catch (e) {
      print('Error saving: $e');
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
