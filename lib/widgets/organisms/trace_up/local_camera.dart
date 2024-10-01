import 'dart:io';
import 'dart:convert'; // JSON操作のために追加
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
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart'; // 追加
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:typed_data';

class Local_Camera extends StatefulWidget {
  @override
  _Local_CameraState createState() => _Local_CameraState();
}

class _Local_CameraState extends State<Local_Camera> {
  final ImagePicker _picker = ImagePicker(); // 画像選択ライブラリ
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firebase Firestore
  late String _selectedUserId; // 選択されたユーザーのID
  bool _isUploading = false; // アップロード中かどうかを示すフラグ
  final int _maxCount = 10; // サークルチャートの最大数

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
      case 'trace_swamp':
        return 'ぬた場';
      case 'trace_mudscrub':
        return '泥こすり痕';
      case 'trace_hornscrub':
        return '角/牙 擦り痕';
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

  // 有効な痕跡数をカウントするメソッド
  Future<int> _getValidTraceCount() async {
    List<PhotoData> traces = await _loadTraces();
    return traces
        .where((photo) =>
            photo.animalType != 'start_flag' &&
            photo.animalType != 'stop_flag' &&
            photo.uploadedFlag == 0)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<PhotoData>>(
        future: _loadTraces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ローディング中
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // エラー発生時
            return Center(child: Text('エラーが発生しました'));
          } else {
            // データが存在する場合
            List<PhotoData> traces = snapshot.data!;
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/bg_image.png'), // 背景画像を指定
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  // 痕跡の撮影枚数とサークルチャートを表示するカード
                  _buildTraceCountCard(traces),
                  Expanded(
                    child: ListView.builder(
                      itemCount: traces.length,
                      itemBuilder: (context, index) {
                        PhotoData data = traces[index];
                        return Card(
                          key: ValueKey(data.image.path),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.file(
                                data.image,
                                width: 120.0,
                                height: 120.0,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('獣種: ${getAnimalType(data.animalType)}'),
                                    SizedBox(height: 4.0),
                                    Text('痕跡種: ${getTraceType(data.traceType)}'),
                                    SizedBox(height: 4.0),
                                    Text('メモ: ${data.memo}'),
                                    SizedBox(height: 4.0),
                                    Text('投稿済み: ${data.uploadedFlag == 1 ? "はい" : "いいえ"}'),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.green[800]),
                                    onPressed: () => _editPhotoData(index, data),
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
            );
          }
        },
      ),
    );
  }

  // 痕跡の撮影枚数とサークルチャートを表示するカード
  Widget _buildTraceCountCard(List<PhotoData> traces) {
    int validTraceCount = traces
        .where((photo) =>
            photo.animalType != 'start_flag' &&
            photo.animalType != 'stop_flag' &&
            photo.uploadedFlag == 0)
        .length;
    double progress = (validTraceCount % _maxCount) / _maxCount;
    int fullRounds = (validTraceCount / _maxCount).floor();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 痕跡撮影枚数の表示
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '痕跡撮影枚数',
                  style: TextStyle(fontSize: 16, fontFamily: "Noto Sans JP"),
                ),
                Text(
                  '$validTraceCount / $_maxCount',
                  style: TextStyle(fontSize: 20, color: Colors.green[900]),
                ),
              ],
            ),
            // サークルチャート
            SizedBox(
              width: 105.0,
              height: 105.0,
              child: PieChart(
                PieChartData(
                  sections: _getSections(progress, fullRounds),
                  centerSpaceRadius: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // チャートのセクションを生成し、1周目と2周目で色を変える
  List<PieChartSectionData> _getSections(double progress, int fullRounds) {
    return List.generate(10, (index) {
      bool isSecondRound = index < (progress * _maxCount);
      return PieChartSectionData(
        color: isSecondRound
            ? Colors.green[400] // 2周目の濃い色
            : Colors.green[100], // 1周目の薄い色
        radius: 30,
      );
    });
  }

  Future<void> _editPhotoData(int index, PhotoData originalData) async {
    // 編集用のダイアログを表示し、新しいデータを取得
    Map<String, dynamic>? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimalTypeMemoWizard(image: originalData.image);
      },
    );

    if (result != null) {
      // 新しいデータを作成
      PhotoData newData = PhotoData(
        image: originalData.image,
        imageUrl: '',
        animalType: result['animalType'] ?? 'error',
        traceType: result['traceType'] ?? 'error',
        memo: result['memo'] ?? '',
        elapsedForTrace: result['elapsed_for_trace'] ?? '',
        confidence: result['confidence'] ?? '',
        position: originalData.position,
        captureTime: originalData.captureTime,
        uploadedFlag: originalData.uploadedFlag,
      );

      // txtファイルを更新
      await _updateTraceAtIndex(index, newData);
      setState(() {}); // UIを更新
    }
  }

  Future<void> _updateTraceAtIndex(int index, PhotoData newData) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/traces.txt';
    final file = File(filePath);

    if (await file.exists()) {
      final content = await file.readAsString();
      List<dynamic> traces = json.decode(content);
      // 該当するエントリを更新
      traces[index] = {
        'imagePath': newData.image.path,
        'animalType': newData.animalType,
        'traceType': newData.traceType,
        'memo': newData.memo,
        'elapsedForTrace': newData.elapsedForTrace,
        'confidence': newData.confidence,
        'position': {
          'latitude': newData.position.latitude,
          'longitude': newData.position.longitude,
        },
        'uploadedFlag': newData.uploadedFlag,
        'captureTime': newData.captureTime.toIso8601String(),
      };
      // txtファイルに書き込む
      await file.writeAsString(json.encode(traces));
    }
  }

  Future<void> _confirmDelete(int index) async {
    bool? deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('削除の確認'),
          content: Text('この写真を削除しますか？'),
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
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/traces.txt';
      final file = File(filePath);

      if (await file.exists()) {
        final content = await file.readAsString();
        List<dynamic> traces = json.decode(content);
        // 該当するエントリを削除
        traces.removeAt(index);
        // txtファイルを更新
        await file.writeAsString(json.encode(traces));
        setState(() {});
      }
    }
  }

  Future<void> _takePicture() async {
    final imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      final DateTime captureTime = DateTime.now();

      // 撮影時間をファイル名としてフォーマット
      final String formattedTime =
          captureTime.toIso8601String().replaceAll(':', '-');

      // 画像のパスを取得
      final image = File(imageFile.path);

      // 撮影時間をファイル名として画像をローカルに保存
      final String newPath = '${image.parent.path}/$formattedTime.jpg';
      final File newImage =
          await image.copy(newPath); // 新しいパスにファイルをコピー

      // ギャラリーに画像を保存
      final bytes = await newImage.readAsBytes();
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(bytes),
          name: formattedTime);
      print('******画像の保存結果: $result******');
      if (result['isSuccess']) {
        Position position = await _getCurrentLocation();
        await _showAnimalTypeMemoDialog(
            newImage, position, captureTime, formattedTime); // 撮影時間とフォーマットされた時間を渡す
      } else {
        print('ローカルへの保存に失敗しました');
      }
    }
  }

  Future<void> _showAnimalTypeMemoDialog(File image, Position position,
      DateTime captureTime, String formattedTime) async {
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

      // 新しいPhotoDataを作成
      PhotoData photoData = PhotoData(
        image: image,
        imageUrl: '',
        animalType: animalType,
        traceType: traceType,
        memo: memo,
        position: position,
        elapsedForTrace: elapsedForTrace,
        confidence: confidence,
        captureTime: captureTime, // 撮影日時を保存
        uploadedFlag: 0, // 新規データなので未投稿フラグは0
      );

      // 痕跡情報を保存
      await _saveTraceInfo(photoData);
      setState(() {}); // UIを更新
    }
  }

  Future<void> _saveTraceInfo(PhotoData photoData) async {
    // ローカルのtxtファイルのパスを取得
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/traces.txt';
    final file = File(filePath);
    print("--------------Lord Local filePath: $filePath--------------");

    // 既存のデータを読み込む
    List<dynamic> traces = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        traces = json.decode(content);
      }
    }

    // 新しいデータを追加
    Map<String, dynamic> newTrace = {
      'imagePath': photoData.image.path,
      'animalType': photoData.animalType,
      'traceType': photoData.traceType,
      'memo': photoData.memo,
      'elapsedForTrace': photoData.elapsedForTrace,
      'confidence': photoData.confidence,
      'position': {
        'latitude': photoData.position.latitude,
        'longitude': photoData.position.longitude,
      },
      'uploadedFlag': 0,
      'captureTime': photoData.captureTime.toIso8601String(),
    };
    traces.add(newTrace);

    // txtファイルに書き込む
    await file.writeAsString(json.encode(traces));
  }

  Future<List<PhotoData>> _loadTraces() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/traces.txt';
    final file = File(filePath);
    print("--------------Loard Local filePath: $filePath--------------");
    List<PhotoData> traces = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        List<dynamic> jsonData = json.decode(content);
        for (var item in jsonData) {
          traces.add(PhotoData(
            image: File(item['imagePath']),
            imageUrl: '',
            animalType: item['animalType'],
            traceType: item['traceType'],
            memo: item['memo'],
            elapsedForTrace: item['elapsedForTrace'],
            confidence: item['confidence'],
            position: Position(
              latitude: item['position']['latitude'],
              longitude: item['position']['longitude'],
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0,
              timestamp: DateTime.parse(item['captureTime']), // 修正
              accuracy: 0.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
            ),
            captureTime: DateTime.parse(item['captureTime']),
            uploadedFlag: item['uploadedFlag'],
          ));
        }
      }
    }
    return traces;
  }

  Future<void> _uploadImages() async {
    // ネットワーク接続を確認
    if (!(await _isConnectedToNetwork())) {
      // エラーダイアログを表示
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

    // アップロード確認のダイアログを表示
    bool confirmUpload = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('回線速度確認'),
          content: Text('回線速度が安定した場所にいますか？安定している場合はアップロードを続行してください。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 「いいえ」選択時
              },
              child: Text('いいえ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 「はい」選択時
              },
              child: Text('はい'),
            ),
          ],
        );
      },
    );

    if (!confirmUpload) {
      // ユーザーが「いいえ」を選択した場合、アップロード中止
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/traces.txt';
    final file = File(filePath);
    print("--------------filePath: $filePath--------------");

    if (await file.exists()) {
      final content = await file.readAsString();
      List<dynamic> traces = json.decode(content);

      for (int i = 0; i < traces.length; i++) {
        var data = traces[i];
        if (data['uploadedFlag'] == 0) {
          try {
            // 画像をアップロード
            String imageUrl = await _uploadImage(
              File(data['imagePath']),
              data['animalType'],
              Position(
                latitude: data['position']['latitude'],
                longitude: data['position']['longitude'],
                altitudeAccuracy: 0.0,
                headingAccuracy: 0.0,
                timestamp: DateTime.parse(data['captureTime']), // 修正
                accuracy: 0.0,
                altitude: 0.0,
                heading: 0.0,
                speed: 0.0,
                speedAccuracy: 0.0,
              ),
              DateTime.parse(data['captureTime']),
            );

            // Firebaseにデータを保存
            await _saveToFirestore(
              Position(
                latitude: data['position']['latitude'],
                longitude: data['position']['longitude'],
                altitudeAccuracy: 0.0,
                headingAccuracy: 0.0,
                timestamp: DateTime.parse(data['captureTime']), // 正しいタイムスタンプを使用
                accuracy: 0.0,
                altitude: 0.0,
                heading: 0.0,
                speed: 0.0,
                speedAccuracy: 0.0,
              ),
              imageUrl,
              data['animalType'],
              data['memo'],
              data['elapsedForTrace'],
              data['traceType'],
              _selectedUserId,
              data['confidence'],
              DateTime.parse(data['captureTime']) // captureTimeを渡す
            );

            // uploadedFlagを1に更新
            traces[i]['uploadedFlag'] = 1;
          } catch (e) {
            print('アップロード中にエラーが発生しました: $e');
          }
        }
      }
      // txtファイルを更新
      await file.writeAsString(json.encode(traces));
    }

    setState(() {
      _isUploading = false;
    });

    // アップロード完了のダイアログを表示
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('アップロード完了'),
          content: Text('すべての画像がアップロードされました。'),
        );
      },
    );
  }

  Future<bool> _isConnectedToNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _saveToFirestore(
      Position position,
      String imageUrl,
      String animalType,
      String memo,
      String elapsedForTrace,
      String traceType,
      String selectedUserId,
      String confidence,
      DateTime captureTime) async { // captureTimeを引数に追加
    await _firestore.collection('wildlife_trace').add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'url': imageUrl,
      'timestamp': captureTime, // DateTime.now()の代わりにcaptureTimeを使用
      'AnimalType': animalType,
      'Memo': memo,
      'ElapsedForTrace': elapsedForTrace,
      'TraceType': traceType,
      'User_ID': selectedUserId,
      'Confidence': confidence,
    });
  }


  Future<String> _uploadImage(
      File image, String animalType, Position position, DateTime captureTime) async {
    final storage = FirebaseStorage.instance;
    final folderPath = 'images/$animalType';

    // 撮影時の日時をファイル名として使用
    final String formattedTime = captureTime.toIso8601String().replaceAll(':', '-');
    final ref = storage.ref().child('$folderPath/$formattedTime.jpg');

    // メディアタイプをimage/jpegとして指定
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    // ファイルをアップロード
    await ref.putFile(image, metadata);

    // 画像のダウンロードURLを取得
    return await ref.getDownloadURL();
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
