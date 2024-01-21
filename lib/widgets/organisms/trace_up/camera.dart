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
    // 利用可能なカメラを取得し、最初のカメラを初期化します。
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
    // ウィジェットが破棄される際にカメラコントローラーを破棄します。
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
                // 写真を撮影またはアップロードするための浮動アクションボタン。
                FloatingActionButton(
                  onPressed: _capturedPhotos.isNotEmpty
                      ? _uploadPhotos
                      : () => _showInputDialog(),
                  child: _capturedPhotos.isNotEmpty
                      ? Icon(Icons.cloud_upload)
                      : Icon(Icons.camera),
                ),
                // 写真がキャプチャされた場合に状態をリセットする追加のボタン。
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
    // 写真をキャプチャする前にユーザーと動物の種類を選択するダイアログを表示します。
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ユーザーと動物の種類を選択'),
          content: Column(
            children: [
              // ユーザーIDを選択するためのドロップダウン。
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
                    child: Text('ユーザー ${index + 1}'),
                  );
                }),
                decoration:
                    InputDecoration(labelText: 'ユーザーIDを選択'), // ユーザーIDの選択
              ),
              // 動物の種類を選択するためのドロップダウン。
              DropdownButtonFormField<String>(
                value: _selectedAnimalType,
                onChanged: (String? value) {
                  setState(() {
                    _selectedAnimalType = value;
                  });
                },
                items: ['イノシシ', 'シカ'].map((animalType) {
                  return DropdownMenuItem<String>(
                    value: animalType,
                    child: Text(animalType),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: '動物の種類を選択'), // 動物の種類の選択
              ),
            ],
          ),
          actions: <Widget>[
            // ダイアログ内のキャンセルボタン。
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // ダイアログ内の写真をキャプチャするボタン。
            TextButton(
              child: Text('キャプチャ'),
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
    // 写真を撮影し、キャプチャされた写真をリストに追加します。
    if (!_controller.value.isInitialized) {
      await _controller.initialize();
    }

    final XFile file = await _controller.takePicture();
    setState(() {
      _capturedPhotos.add(File(file.path));
    });
  }

  Future<void> _uploadPhotos() async {
    // キャプチャされた写真をFirebase Storageにアップロードします。
    if (_capturedPhotos.isEmpty) {
      return; // アップロードする写真がありません
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
        print('写真のアップロードエラー: $e');
        _showErrorDialog();
      }
    }

    _showSnackBar('写真が正常にアップロードされました');
    _resetState();
  }

  void _resetState() {
    // キャプチャされた写真と選択された値をクリアして状態をリセットします。
    setState(() {
      _capturedPhotos.clear();
      _selectedUserId = null;
      _selectedAnimalType = null;
    });
  }

  void _showSnackBar(String message) {
    // メッセージを含むスナックバーを表示します。
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    ));
  }

  void _showErrorDialog() {
    // 写真のアップロードに問題がある場合にエラーダイアログを表示します。
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text('写真のアップロードに失敗しました。もう一度お試しください。'),
          actions: <Widget>[
            // エラーダイアログ内のOKボタン。
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
