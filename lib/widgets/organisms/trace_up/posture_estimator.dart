// lib/widgets/organisms/trace_up/posture_estimator.dart

import 'dart:async';
import 'dart:io';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';

class PostureEstimator {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  late File _logFile;
  late IOSink _sink;

  // セッション開始時に呼び出す
  Future<void> startEstimation(String sessionId) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/user_log_$sessionId.txt';
    _logFile = File(filePath);
    _sink = _logFile.openWrite(mode: FileMode.append);

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      final timestamp = DateTime.now().toIso8601String();
      _sink.writeln(
          '$timestamp, x: ${event.x.toStringAsFixed(3)}, y: ${event.y.toStringAsFixed(3)}, z: ${event.z.toStringAsFixed(3)}');
    });
  }

  // セッション終了時に呼び出す
  Future<void> stopEstimation() async {
    await _accelerometerSubscription?.cancel();
    await _sink.close();
  }
}
