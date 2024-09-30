// photo_data.dart
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class PhotoData {
  final File image;
  final String imageUrl;
  final String animalType;
  final String traceType;
  final String memo;
  final Position position;
  final String elapsedForTrace;
  final String confidence;
  final DateTime captureTime;
  int uploadedFlag;  

  PhotoData({
    required this.image,
    required this.imageUrl,
    required this.animalType,
    required this.traceType,
    required this.memo,
    required this.position,
    required this.elapsedForTrace,
    required this.confidence,
    required this.captureTime,
    this.uploadedFlag = 0,
  });
}

