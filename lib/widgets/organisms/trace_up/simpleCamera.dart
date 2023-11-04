import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatefulWidget {
  @override
  _CameraPreviewWidgetState createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  late CameraController controller;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    // カメラの一覧を取得
    availableCameras().then((cameraList) {
      setState(() {
        cameras = cameraList;
      });
      if (cameras.isNotEmpty) {
        // 最初のカメラを使用
        controller = CameraController(cameras[0], ResolutionPreset.medium);
        controller.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  // カメラで写真を撮影するメソッド
  Future<void> takePicture() async {
    if (!controller.value.isInitialized) {
      return;
    }
    final XFile imageFile = await controller.takePicture();
    // 撮影した画像ファイル(imageFile)を使って何かしらの処理を行うことができます
  }
}
