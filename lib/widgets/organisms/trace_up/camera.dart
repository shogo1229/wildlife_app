import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TraceCamera extends StatefulWidget {
  @override
  _TraceCameraState createState() => _TraceCameraState();
}

class _TraceCameraState extends State<TraceCamera> {
  late CameraController _controller;
  List<File> _capturedPhotos = [];
  int? _selectedUserId;
  String? _selectedAnimalType;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    await _controller.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _capturedPhotos.isNotEmpty
                  ? Image.file(_capturedPhotos.last)
                  : CameraPreview(_controller),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _capturedPhotos.isNotEmpty
                      ? _uploadPhotos
                      : () => _showInputDialog(),
                  child: _capturedPhotos.isNotEmpty
                      ? Icon(Icons.cloud_upload)
                      : Icon(Icons.camera),
                ),
                if (_capturedPhotos.isNotEmpty)
                  FloatingActionButton(
                    onPressed: _resetState,
                    child: Icon(Icons.refresh),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(),
    );
  }

  Future<void> _showInputDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select User and Animal Type'),
          content: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedUserId,
                onChanged: (int? value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                },
                items: List.generate(10, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('User ${index + 1}'),
                  );
                }),
                decoration: InputDecoration(labelText: 'Select User ID'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedAnimalType,
                onChanged: (String? value) {
                  setState(() {
                    _selectedAnimalType = value;
                  });
                },
                items: ['Boar', 'Deer'].map((animalType) {
                  return DropdownMenuItem<String>(
                    value: animalType,
                    child: Text(animalType),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Animal Type'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Capture'),
              onPressed: () {
                Navigator.of(context).pop();
                _takePicture();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) {
      await _controller.initialize();
    }

    final XFile file = await _controller.takePicture();
    setState(() {
      _capturedPhotos.add(File(file.path));
    });
  }

  Future<void> _uploadPhotos() async {
    if (_capturedPhotos.isEmpty) {
      return; // No photos to upload
    }

    final FirebaseStorage storage = FirebaseStorage.instance;

    for (int i = 0; i < _capturedPhotos.length; i++) {
      final String timestamp = DateTime.now().toIso8601String();
      final String fileName = 'photo\_$timestamp\_$i.jpg';
      final Reference storageRef =
          storage.ref().child('photos').child(fileName);

      try {
        final UploadTask uploadTask = storageRef.putFile(_capturedPhotos[i]);
        await uploadTask.whenComplete(() async {
          final String photoURL = await storageRef.getDownloadURL();
          print(photoURL);
        });
      } catch (e) {
        print('Error uploading photo: $e');
        _showErrorDialog();
      }
    }

    _showSnackBar('Photos uploaded successfully');
    _resetState();
  }

  void _resetState() {
    setState(() {
      _capturedPhotos.clear();
      _selectedUserId = null;
      _selectedAnimalType = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    ));
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to upload the photos. Please try again.'),
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
}
