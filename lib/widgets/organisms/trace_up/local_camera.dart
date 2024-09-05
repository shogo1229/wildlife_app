import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/photo_data.dart';
import 'package:wildlife_app/widgets/organisms/home/user_selection.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/animal_type_memo_wizard.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart'; // 追加
import 'package:flutter/services.dart'; // 追加
import 'dart:ui' as ui;

Future<File> _resizeImage(File imageFile) async {
  // 画像ファイルをバイトデータとして読み込む
  final bytes = await imageFile.readAsBytes();
  // バイトデータから画像をデコードする
  final ui.Image originalImage = await decodeImageFromList(bytes);

  // 新しい画像の幅と高さを半分に設定
  final int newWidth = (originalImage.width / 2).round();
  final int newHeight = (originalImage.height / 2).round();

  // 画像をリサイズ
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Paint paint = Paint();
  final Rect src = Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble());
  final Rect dst = Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble());

  canvas.drawImageRect(originalImage, src, dst, paint);
  final ui.Image resizedImage = await recorder.endRecording().toImage(newWidth, newHeight);

  // リサイズされた画像をバイトデータに変換
  final ByteData? resizedBytes = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List resizedImageData = resizedBytes!.buffer.asUint8List();

  // リサイズされた画像を一時ファイルとして保存
  final tempDir = Directory.systemTemp;
  final resizedImageFile = await File('${tempDir.path}/resized_image.png').writeAsBytes(resizedImageData);

  return resizedImageFile;
}

class Local_Camera extends StatefulWidget {
  @override
  _Local_CameraState createState() => _Local_CameraState();
}

class _Local_CameraState extends State<Local_Camera> {
  static List<PhotoData> _pendingUploadImages = []; // アップロード待ちの写真データのリスト
  final ImagePicker _picker = ImagePicker(); // 画像選択ライブラリ
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firebase Firestore
  late String _selectedUserId; // 選択されたユーザーのID
  bool _isUploading = false; // アップロード中かどうかを示すフラグ

  @override
  void initState() {
    super.initState();
    _selectedUserId = context.read<UserProvider>().getUserId(); // Get userId as String
  }

  String getTraceType(String traceType) {
    switch (traceType) {
      case 'trace_footprint':
        return '足跡';
      case 'trace_dropping':
        return '糞';
      case 'trace_others':
        return 'ぬた場';
      case 'trace_swamp':
        return 'ぬた場';
      case 'trace_mudscrub':
        return '泥こすり痕';
      case 'trace_hornscrub':
        return '泥こすり痕';
      case 'trace_others':
        return 'その他';
      case 'camera':
        return 'カメラ';
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
      case 'start_flag':
        return '開始確認';
      case 'stop_flag':
        return '終了確認';
      default:
        return 'error'; // Handle unknown trace types if needed
    }
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/images/bg_image.png'), // 背景画像を指定
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _pendingUploadImages.length,
                  itemBuilder: (context, index) {
                    return Card(
                      key: ValueKey(_pendingUploadImages[index].image.path),
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          Image.file(
                            _pendingUploadImages[index].image,
                            width: 120.0,
                            height: 120.0,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('獣種: ${getAnimalType(_pendingUploadImages[index].animalType)}'),
                                SizedBox(height: 4.0),
                                Text('痕跡種: ${getTraceType(_pendingUploadImages[index].traceType)}'),
                                SizedBox(height: 4.0),
                                Text('メモ: ${_pendingUploadImages[index].memo}'),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.green[800]),
                                onPressed: () => _editPhotoData(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _takePicture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[900],
                      foregroundColor: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.camera),
                        SizedBox(width: 8),
                        Text('痕跡を撮影'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green[900],
                    ),
                    child: _isUploading
                        ? Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 8),
                              Text('アップロード中...'),
                            ],
                          )
                        : Row(
                            children: [
                              Icon(Icons.upload),
                              SizedBox(width: 8),
                              Text('アップロード'),
                            ],
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

  Future<void> _editPhotoData(int index) async {
    Map<String, dynamic>? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimalTypeMemoWizard(image: _pendingUploadImages[index].image);
      },
    );

    if (result != null) {
      setState(() {
        _pendingUploadImages[index].animalType = result['animalType'] ?? 'error';
        _pendingUploadImages[index].traceType = result['traceType'] ?? 'error';
        _pendingUploadImages[index].memo = result['memo'] ?? '';
        _pendingUploadImages[index].elapsedForTrace = result['elapsed_for_trace'] ?? '';
        _pendingUploadImages[index].confidence = result['confidence'] ?? '';
      });
    }
  }

  Future<void> _confirmDelete(int index) async {
    bool? deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('取消の確認'),
          content: Text('この写真を取り消しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('いいえ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('はい', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      setState(() {
        _pendingUploadImages.removeAt(index);
      });
    }
  }

  Future<void> _takePicture() async {
    final imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      final image = File(imageFile.path);

      // 画像をギャラリーに保存
      final bytes = await image.readAsBytes();
      final result = await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));

      if (result['isSuccess']) {
        Position position = await _getCurrentLocation();
        await _showAnimalTypeMemoDialog(image, position);
      } else {
        print('Error saving image to gallery');
      }
    }
  }

  Future<void> _showAnimalTypeMemoDialog(File image, Position position) async {
    Map<String, dynamic>? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimalTypeMemoWizard(image: image);
      },
    );

    if (result != null) {
      String animalType = result['animalType'] ?? 'error';
      String traceType = result['traceType'] ?? 'error';
      String memo = result['memo'];
      String elapsedForTrace = result['elapsed_for_trace'] ?? '';
      String confidence = result['confidence'] ?? '';

      setState(() {
        _pendingUploadImages.add(PhotoData(
          image: image,
          imageUrl: '',
          animalType: animalType,
          traceType: traceType,
          memo: memo,
          position: position,
          elapsedForTrace: elapsedForTrace,
          confidence: confidence,
        ));
      });
    }
  }

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

    setState(() {
      _isUploading = true; // アップロード中であることを示す
    });

    List<PhotoData> imagesCopy = List.from(_pendingUploadImages);

    for (var data in imagesCopy) {
      try {
        data.imageUrl = await _uploadImage(data.image, data.animalType, data.position);
        await _saveToFirestore(data.position, data.imageUrl, data.animalType, data.memo, data.elapsedForTrace, data.traceType,_selectedUserId,data.confidence);
        await _updateUserTotalPoints(_selectedUserId, imagesCopy.length);
        await _updateAnimalPoints(_selectedUserId, data.animalType);

        setState(() {
          _pendingUploadImages.remove(data);
        });
        
      } catch (e) {
        print('Error during image upload: $e');
      }
    }

    setState(() {
      _isUploading = false; // アップロード完了後にフラグをリセット
    });

    if (_pendingUploadImages.isEmpty) {
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

  Future<void> _updateUserTotalPoints(String userId, int numberOfPhotos) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('User_Information')
          .where('User_ID', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs[0];
        await doc.reference.update({
          'total_point': FieldValue.increment(numberOfPhotos),
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

  Future<String> _uploadImage(
      File image, String animalType, Position position) async {
    final storage = FirebaseStorage.instance;
    final folderPath = 'images/$animalType';
    final ref = storage.ref().child('$folderPath/${DateTime.now()}.jpg');

    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _saveToFirestore(Position position, String imageUrl,
      String animalType, String memo, String elapsedForTrace, String traceType, String selectedUserId, String confidence) async {
    await _firestore.collection('wildlife_trace').add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'url': imageUrl,
      'timestamp': DateTime.now(),
      'AnimalType': animalType,
      'Memo': memo,
      'ElapsedForTrace': elapsedForTrace,
      'TraceType': traceType,
      'User_ID': selectedUserId,
      'Confidence': confidence, // 追加
    });
  }


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
