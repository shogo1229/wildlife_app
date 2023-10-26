import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:location/location.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final XFile photo;
  final Function onRetake;
  final Function onSave;
  final LocationData? locationData;

  PhotoPreviewScreen({
    Key? key,
    required this.photo,
    required this.onRetake,
    required this.onSave,
    required this.locationData,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.locationData != null
                  ? 'Latitude: ${widget.locationData!.latitude}, Longitude: ${widget.locationData!.longitude}'
                  : 'Location information not available',
              style: TextStyle(fontSize: 18),
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
