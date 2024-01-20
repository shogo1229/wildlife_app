import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:location/location.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final XFile photo;
  final Function onRetake;
  final Function onSave;
  final LocationData? locationData;
  final String userID;
  final String animalType;

  PhotoPreviewScreen({
    Key? key,
    required this.photo,
    required this.onRetake,
    required this.onSave,
    required this.locationData,
    required this.userID,
    required this.animalType,
  }) : super(key: key);

  @override
  _PhotoPreviewScreenState createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(File(widget.photo.path)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 位置情報の表示
                Text(
                  widget.locationData != null
                      ? 'Latitude: ${widget.locationData!.latitude}, Longitude: ${widget.locationData!.longitude}'
                      : 'Location information not available',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                // ユーザーIDの表示
                Text(
                  'UserID: ${widget.userID}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                // 動物の種類の表示
                Text(
                  'Animal Type: ${widget.animalType}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 再撮影ボタン
              ElevatedButton(
                onPressed: () {
                  widget.onRetake();
                },
                child: Text('Retake'),
              ),
              SizedBox(width: 16),
              // 保存ボタン
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
