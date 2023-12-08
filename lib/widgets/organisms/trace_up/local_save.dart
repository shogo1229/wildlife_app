import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Local_Camera extends StatefulWidget {
  @override
  _Local_CameraState createState() => _Local_CameraState();
}

class _Local_CameraState extends State<Local_Camera> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Upload App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Image.file(_images[index]),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _takePicture,
            child: Text('Take Picture'),
          ),
          ElevatedButton(
            onPressed: _uploadImages,
            child: Text('Upload Images'),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    final imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      setState(() {
        _images.add(File(imageFile.path));
      });
    }
  }

  Future<void> _uploadImages() async {
    for (var image in _images) {
      try {
        // Check if network is available
        if (await _isConnectedToNetwork()) {
          await _uploadImage(image);
          setState(() {
            _images.remove(image);
          });
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    if (_images.isEmpty) {
      // All images uploaded
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Upload Complete'),
            content: Text('All images have been uploaded.'),
          );
        },
      );
    }
  }

  Future<void> _uploadImage(File image) async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('images/${DateTime.now()}.jpg');
    await ref.putFile(image);
  }

  Future<bool> _isConnectedToNetwork() async {
    // Implement your network connectivity check logic here
    // For example, you can use the connectivity package
    // https://pub.dev/packages/connectivity
    return true;
  }
}
