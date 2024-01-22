// widgets/local_camera_widget.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/local_save.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/photo_data.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/user_information.dart';

class LocalCameraWidget extends StatefulWidget {
  @override
  _LocalCameraWidgetState createState() => _LocalCameraWidgetState();
}

class _LocalCameraWidgetState extends State<LocalCameraWidget> {
  static List<PhotoData> _images = []; // アプリ内で管理する写真データのリスト
  final ImagePicker _picker = ImagePicker(); // 画像選択ライブラリ
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firebase Firestore
  late String _selectedUserId; // 選択されたユーザーのID

  String getTraceType(String traceType) {
    switch (traceType) {
      case 'animal_footprint':
        return '足跡';
      case 'animal_dropping':
        return '糞';
      case 'bark-stripping':
        return '樹皮剥ぎ跡';
      case 'horn-rubbing':
        return '角こすり跡';
      case 'animal-trail':
        return '獣道';
      default:
        return 'Unknown'; // Handle unknown trace types if needed
    }
  }

  String getAnimalType(String animalType) {
    switch (animalType) {
      case 'Boar':
        return 'イノシシ';
      case 'Deer':
        return 'シカ';
      case 'Other':
        return 'その他/不明';
      default:
        return 'error'; // Handle unknown trace types if needed
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedUserId =
        context.read<UserProvider>().getUserId(); // Get userId as String
  }

  @override
  Widget build(BuildContext context) {
    // 画像を表示し、写真を撮影し、画像をアップロードするための UI
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              // GridView内で写真を表示
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    GridTile(
                      child: Expanded(
                        child: Image.file(_images[index].image),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        '獣種: ${getAnimalType(_images[index].animalType)}',
                        style: TextStyle(fontSize: 12.0),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '痕跡種: ${getTraceType(_images[index].traceType)}',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          Text(
                            '緯度: ${_images[index].position.latitude}',
                            style: TextStyle(fontSize: 10.0),
                          ),
                          Text(
                            '経度: ${_images[index].position.longitude}',
                            style: TextStyle(fontSize: 10.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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

  // 写真を撮影し AnimalTypeMemoPage を表示する関数
  Future<void> _takePicture() async {
    final imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      Position position = await _getCurrentLocation();
      _showAnimalTypeMemoDialog(File(imageFile.path), position);
    }
  }

  // AnimalTypeMemoPage ダイアログを表示する関数
  Future<void> _showAnimalTypeMemoDialog(File image, Position position) async {
    Map<String, dynamic>? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimalTypeMemoPage(image: image);
      },
    );

    if (result != null) {
      String animalType = result['animalType'];
      String traceType = result['traceType'] ?? ''; // Corrected here
      String memo = result['memo'];

      setState(() {
        _images.add(PhotoData(
          image: image,
          imageUrl: '',
          animalType: animalType,
          traceType: traceType, // Corrected here
          memo: memo,
          position: position,
        ));
      });
    }
  }

  // 画像をアップロードしポイントを更新する関数
  Future<void> _uploadImages() async {
    if (!(await _isConnectedToNetwork())) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ネットワーク接続エラー'),
            content: Text('ネットワークに接続されていません。画像のアップロードは行えません。'),
          );
        },
      );
      return;
    }

    List<PhotoData> imagesCopy = List.from(_images);

    for (var data in imagesCopy) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return UploadProgressModal(
              message:
                  'Uploading ${_images.indexOf(data) + 1}/${_images.length}',
            );
          },
        );

        Position position = data.position;

        data.imageUrl =
            await _uploadImage(data.image, data.animalType, position);
        await _saveToFirestore(position, data.imageUrl, data.animalType,
            data.memo, _selectedUserId);

        await _updateUserTotalPoints(_selectedUserId, imagesCopy.length);
        await _updateAnimalPoints(_selectedUserId, data.animalType);

        setState(() {
          _images.remove(data);
        });

        Navigator.pop(context); // 進捗ダイアログを閉じる
      } catch (e) {
        print('Error during image upload: $e');
        Navigator.pop(context); // 進捗ダイアログを閉じる
      }
    }

    setState(() {
      _images = _images.where((data) => data.imageUrl.isNotEmpty).toList();
    });

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

  // 動物のポイントを更新する関数
  Future<void> _updateAnimalPoints(String userId, String animalType) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('User_Information')
          .where('User_ID', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs[0];
        await doc.reference.update({
          '${animalType}_Point': FieldValue.increment(1),
        });
      } else {
        await FirebaseFirestore.instance.collection('User_Information').add({
          'User_ID': userId,
          'Boar_Point': 0,
          'Deer_Point': 0,
          'Other_Point': 0,
          'total_point': 0,
        });
      }
    } catch (e) {
      print('Error updating animal-specific points: $e');
    }
  }

  // ユーザーの総ポイントを更新する関数
  Future<void> _updateUserTotalPoints(String userId, int numberOfPhotos) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('User_Information')
          .where('User_ID', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs[0];
        await doc.reference.update({
          'total_point': FieldValue.increment(1),
        });
      } else {
        await FirebaseFirestore.instance.collection('User_Information').add({
          'User_ID': userId,
          'Boar_Point': 0,
          'Deer_Point': 0,
          'Other_Point': 0,
          'total_point': numberOfPhotos,
        });
      }
    } catch (e) {
      print('Error updating user total points: $e');
    }
  }

  // 画像をFirebase Storageにアップロードする関数
  Future<String> _uploadImage(
      File image, String animalType, Position position) async {
    final storage = FirebaseStorage.instance;
    final folderPath = 'images/$animalType';
    final ref = storage.ref().child('$folderPath/${DateTime.now()}.jpg');

    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  // Firestoreに写真情報を保存する関数
  Future<void> _saveToFirestore(Position position, String imageUrl,
      String animalType, String memo, String selectedUserId) async {
    await _firestore.collection('wildlife_trace').add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'url': imageUrl,
      'timestamp': DateTime.now(),
      'AnimalType': animalType,
      'Memo': memo,
      'User_ID': selectedUserId,
    });
  }

  // ネットワーク接続を確認する関数
  Future<bool> _isConnectedToNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
