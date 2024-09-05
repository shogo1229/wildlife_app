// photo_data.dart
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class PhotoData {
  File image;
  String imageUrl;
  String animalType;
  String memo;
  Position position;
  String traceType;
  String elapsedForTrace;
  String confidence;
  final DateTime captureTime;

  PhotoData({
    required this.image,
    required this.imageUrl,
    required this.animalType,
    required this.memo,
    required this.position,
    required this.traceType,
    required this.elapsedForTrace,
    required this.confidence,
    required this.captureTime,
  });
}
