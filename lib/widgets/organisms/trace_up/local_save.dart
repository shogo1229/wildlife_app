import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

// 画像とそのURLを保持するデータモデル
class PhotoData {
  File image; // 画像ファイル
  String imageUrl; // 画像のFirebase Storage上のURL
  PhotoData({required this.image, required this.imageUrl});
}

class Local_Camera extends StatefulWidget {
  @override
  _Local_CameraState createState() => _Local_CameraState();
}

class _Local_CameraState extends State<Local_Camera> {
  // アプリ内で使用する画像のリスト
  static List<PhotoData> _images = [];

  // ImagePickerライブラリのインスタンス
  final ImagePicker _picker = ImagePicker();

  // Firebase Cloud Firestoreのデータベースへのアクセスインスタンス
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 画像を表示するListView.builder
          Expanded(
            child: ListView.builder(
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Image.file(_images[index].image),
                );
              },
            ),
          ),
          // カメラで写真を撮るボタンと画像をアップロードするボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _takePicture,
                child: Text('写真を撮る'),
              ),
              ElevatedButton(
                onPressed: _uploadImages,
                child: Text('画像をアップロード'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // カメラで写真を撮るメソッド
  Future<void> _takePicture() async {
    final imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      setState(() {
        _images.add(PhotoData(image: File(imageFile.path), imageUrl: ''));
      });
    }
  }

  // 画像をアップロードするメソッド
  Future<void> _uploadImages() async {
    // ローカルで画像リストをコピー
    List<PhotoData> imagesCopy = List.from(_images);

    // 画像リストをイテレートしてFirebaseにアップロード
    for (var data in imagesCopy) {
      try {
        // ネットワークに接続されているか確認
        if (await _isConnectedToNetwork()) {
          // 現在のデバイスの位置情報を取得
          Position position = await _getCurrentLocation();

          // 画像をFirebase Storageにアップロードし、そのURLを取得
          data.imageUrl = await _uploadImage(data.image);

          // 位置情報と画像URLをFirestoreに保存
          await _saveToFirestore(position, data.imageUrl);

          // アップロードが成功したらローカルの画像リストから削除
          setState(() {
            _images.remove(data);
          });
        }
      } catch (e) {
        print('画像のアップロード中にエラーが発生しました： $e');
      }
    }

    // 画像リストからURLが空でないものだけを残す
    setState(() {
      _images = _images.where((data) => data.imageUrl.isNotEmpty).toList();
    });

    // すべての画像がアップロードされたらダイアログを表示
    if (_images.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('アップロード完了'),
            content: Text('すべての画像がアップロードされ、ローカルの画像も削除されました。'),
          );
        },
      );
    }
  }

  // 画像をFirebase Storageにアップロードするメソッド
  Future<String> _uploadImage(File image) async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('images/${DateTime.now()}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  // Firestoreに位置情報と画像URLを保存するメソッド
  Future<void> _saveToFirestore(Position position, String imageUrl) async {
    await _firestore.collection('wildlife_trace').add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'url': imageUrl,
      'timestamp': DateTime.now(),
    });
  }

  // ネットワークに接続されているか確認するメソッド
  Future<bool> _isConnectedToNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // 現在のデバイスの位置情報を取得するメソッド
  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
