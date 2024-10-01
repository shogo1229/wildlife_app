// lib/widgets/organisms/trace_up/photo_data.dart

import 'dart:io';
import 'package:geolocator/geolocator.dart';

class PhotoData {
  File image;
  String imageUrl;
  String animalType;
  String traceType;
  String memo;
  String elapsedForTrace;
  String confidence;
  Position position;
  DateTime captureTime;
  int uploadedFlag;

  PhotoData({
    required this.image,
    required this.imageUrl,
    required this.animalType,
    required this.traceType,
    required this.memo,
    required this.elapsedForTrace,
    required this.confidence,
    required this.position,
    required this.captureTime,
    required this.uploadedFlag,
  });

  // JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'imagePath': image.path,
      'imageUrl': imageUrl,
      'animalType': animalType,
      'traceType': traceType,
      'memo': memo,
      'elapsedForTrace': elapsedForTrace,
      'confidence': confidence,
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'captureTime': captureTime.toIso8601String(),
      'uploadedFlag': uploadedFlag,
    };
  }

  // JSONから生成
  factory PhotoData.fromJson(Map<String, dynamic> json) {
    return PhotoData(
      image: File(json['imagePath']),
      imageUrl: json['imageUrl'],
      animalType: json['animalType'],
      traceType: json['traceType'],
      memo: json['memo'],
      elapsedForTrace: json['elapsedForTrace'],
      confidence: json['confidence'],
      position: Position(
        latitude: json['position']['latitude'],
        longitude: json['position']['longitude'],
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
        timestamp: DateTime.parse(json['captureTime']),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      ),
      captureTime: DateTime.parse(json['captureTime']),
      uploadedFlag: json['uploadedFlag'],
    );
  }
}
