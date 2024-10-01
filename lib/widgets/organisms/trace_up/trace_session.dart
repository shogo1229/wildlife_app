// lib/widgets/organisms/trace_up/trace_session.dart

import 'photo_data.dart';

class TraceSession {
  String sessionId;
  DateTime startTime;
  DateTime? endTime;
  List<PhotoData> photos;

  TraceSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.photos,
  });

  // JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'photos': photos.map((photo) => photo.toJson()).toList(),
    };
  }

  // JSONから生成
  factory TraceSession.fromJson(Map<String, dynamic> json) {
    return TraceSession(
      sessionId: json['sessionId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      photos: (json['photos'] as List)
          .map((photoJson) => PhotoData.fromJson(photoJson))
          .toList(),
    );
  }
}
