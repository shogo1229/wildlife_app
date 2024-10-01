import 'dart:io';
import 'dart:convert'; // JSON操作のために追加
import 'dart:async'; // タイマー機能のために追加
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/photo_data.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/trace_session.dart';
import 'package:wildlife_app/widgets/organisms/home/user_selection.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/animal_type_memo_wizard.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart'; // 追加
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_chart/fl_chart.dart';

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

  List<TraceSession> _traceSessions = [];
  TraceSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _selectedUserId = context.read<UserProvider>().getUserId(); // Get userId as String
    _loadSessions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // セッションの読み込み
  Future<void> _loadSessions() async {
    List<TraceSession> sessions = await _loadTraceSessions();
    setState(() {
      _traceSessions = sessions;
      _currentSession = _traceSessions.isNotEmpty &&
              _traceSessions.last.endTime == null
          ? _traceSessions.last
          : null;
    });
  }

  // TraceSessionの保存
  Future<void> _saveTraceSessions(List<TraceSession> sessions) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/trace_sessions.txt';
    final file = File(filePath);
    List<Map<String, dynamic>> jsonSessions =
        sessions.map((session) => session.toJson()).toList();
    await file.writeAsString(json.encode(jsonSessions));
  }

  // TraceSessionの読み込み
  Future<List<TraceSession>> _loadTraceSessions() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/trace_sessions.txt';
    final file = File(filePath);
    List<TraceSession> sessions = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        List<dynamic> jsonData = json.decode(content);
        sessions = jsonData
            .map((sessionJson) => TraceSession.fromJson(sessionJson))
            .toList();
      }
    }
    return sessions;
  }

  // 痕跡種を日本語に変換
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
        return 'Unknown'; // 不明な痕跡種
    }
  }

  // 動物種を日本語に変換
  String getAnimalType(String animalType) {
    switch (animalType) {
      case 'Boar':
        return 'イノシシ';
      case 'Deer':
        return 'シカ';
      case 'Other':
        return 'その他/不明';
      case 'start_flag':
        return '調査開始';
      case 'stop_flag':
        return '調査終了';
      default:
        return 'error'; // 不明な動物種
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBarを削除してホーム画面に戻す（必要に応じて再追加）
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
              child: _traceSessions.isEmpty
                  ? Center(
                      child: Text(
                        '痕跡が撮影されていません',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(8.0),
                      itemCount: _traceSessions.length,
                      separatorBuilder: (context, index) => Divider(thickness: 2),
                      itemBuilder: (context, sessionIndex) {
                        TraceSession session = _traceSessions[sessionIndex];

                        // 投稿済みのセッションは表示しない
                        bool isUploaded = session.photos.every(
                            (photo) => photo.uploadedFlag == 1);
                        if (isUploaded) {
                          return SizedBox.shrink();
                        }

                        // セッション内に投稿されていない写真が存在する場合のみ表示
                        bool hasUnuploadedPhotos = session.photos.any(
                            (photo) => photo.uploadedFlag == 0);

                        if (!hasUnuploadedPhotos) {
                          return SizedBox.shrink();
                        }

                        // トレースセッションが開始されていて、まだ終了していない場合のみタイマーを表示
                        bool isTracing = session.endTime == null;

                        int validTraceCount = session.photos
                            .where((photo) =>
                                photo.animalType != 'start_flag' &&
                                photo.animalType != 'stop_flag' &&
                                photo.uploadedFlag == 0)
                            .length;
                        double progress =
                            (validTraceCount % _maxCount) / _maxCount;
                        int fullRounds =
                            (validTraceCount / _maxCount).floor();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // セッションごとのゲージカードを常に表示
                            _buildTraceCountCard(
                                session, validTraceCount, progress, fullRounds),

                            // セッションが進行中の場合のみ経過時間を表示
                            if (isTracing)
                              ElapsedTimeWidget(startTime: session.startTime),

                            // セッションごとの写真リスト
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: session.photos.length,
                              itemBuilder: (context, photoIndex) {
                                PhotoData data = session.photos[photoIndex];
                                return Card(
                                  key: ValueKey(data.image.path),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.file(
                                          data.image,
                                          width: 120.0,
                                          height: 120.0,
                                          fit: BoxFit.cover,
                                          cacheWidth: 300, // 表示用にリサイズ
                                          cacheHeight: 300,
                                        ),
                                      ),
                                      SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '獣種: ${getAnimalType(data.animalType)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: (data.animalType == 'start_flag' ||
                                                        data.animalType == 'stop_flag')
                                                    ? Colors.blue
                                                    : Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Text(
                                                '痕跡種: ${getTraceType(data.traceType)}'),
                                            SizedBox(height: 4.0),
                                            Text(
                                                '${data.uploadedFlag == 1 ? "投稿済み" : "未投稿"}'),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.green[800]),
                                            onPressed: () => _editPhotoData(
                                                sessionIndex,
                                                photoIndex,
                                                data),
                                          ),
                                          IconButton(
                                            icon:
                                                Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _confirmDelete(
                                                sessionIndex, photoIndex),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),
            // アクションボタン群（アップロードと撮影）
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green[900],
                      padding:
                          EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    ),
                    child: _isUploading
                        ? Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: Colors.green[900],
                                ),
                              ),
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
                  ElevatedButton(
                    onPressed: _takePicture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.camera),
                        SizedBox(width: 8),
                        Text('撮影'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // セッションごとのゲージカードを作成
  Widget _buildTraceCountCard(
      TraceSession session, int validTraceCount, double progress, int fullRounds) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white70,
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
                  sections: _getSections(progress),
                  centerSpaceRadius: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // チャートのセクションを生成
  List<PieChartSectionData> _getSections(double progress) {
    int filledSections = (progress * _maxCount).round();
    return List.generate(10, (index) {
      if (index < filledSections && filledSections <= 10) {
        // 10個以下の撮影の場合
        return PieChartSectionData(
          color: Colors.green[400], // 濃い緑色
          radius: 30,
        );
      } else if (index < 10) {
        // 10個未満の撮影で未塗りの部分
        return PieChartSectionData(
          color: Colors.green[100], // 薄い緑色
          radius: 30,
        );
      } else {
        // 11個以上の撮影の場合、超過部分を赤く表示
        return PieChartSectionData(
          color: Colors.red, // 赤色
          radius: 30,
        );
      }
    });
  }

  // 写真を撮影
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

      try {
        // ファイルをコピー（オリジナルを保持）
        final File newImage = await image.copy(newPath);

        // 画像をギャラリーに保存（オリジナルの解像度を保持）
        final bytes = await newImage.readAsBytes();
        final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(bytes), name: formattedTime);
        print('******画像の保存結果: $result******');
        if (result['isSuccess']) {
          Position position = await _getCurrentLocation();
          await _showAnimalTypeMemoDialog(
              newImage, position, captureTime, formattedTime); // 撮影時間とフォーマットされた時間を渡す
        } else {
          print('ローカルへの保存に失敗しました');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ローカルへの保存に失敗しました')),
          );
        }
      } catch (e) {
        print('画像処理中にエラーが発生しました: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像処理中にエラーが発生しました')),
        );
      }
    }
  }

  // メモダイアログを表示し、写真データを保存
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
        elapsedForTrace: elapsedForTrace,
        confidence: confidence,
        position: position,
        captureTime: captureTime,
        uploadedFlag: 0,
      );

      if (animalType == 'start_flag') {
        // セッションを開始
        _startTracing();

        if (_currentSession != null) {
          setState(() {
            _currentSession!.photos.add(photoData);
          });

          // セッションを保存
          await _saveTraceSessions(_traceSessions);
        } else {
          // セッションが開始できなかった場合
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('セッションを開始できませんでした。')),
          );
        }
      } else if (animalType == 'stop_flag') {
        if (_currentSession != null) {
          setState(() {
            _currentSession!.photos.add(photoData);
          });

          // セッションを保存
          await _saveTraceSessions(_traceSessions);

          // セッションを終了
          _stopTracing();
        } else {
          // セッションが存在しない場合
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('トレースセッションが開始されていません。')),
          );
        }
      } else {
        // その他のanimalTypeの場合
        if (_currentSession != null) {
          setState(() {
            _currentSession!.photos.add(photoData);
          });

          // セッションを保存
          await _saveTraceSessions(_traceSessions);
        } else {
          // セッションが存在しない場合
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('トレースセッションが開始されていません。')),
          );
        }
      }
    }
  }

  // トレース開始
  void _startTracing() {
    if (_currentSession != null) {
      // 既にトレースセッションが開始されている場合
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('既にトレースセッションが開始されています。')),
      );
      return;
    }

    String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    DateTime startTime = DateTime.now();

    TraceSession newSession = TraceSession(
      sessionId: sessionId,
      startTime: startTime,
      photos: [],
    );

    setState(() {
      _traceSessions.add(newSession);
      _currentSession = newSession;
    });

    // セッションを保存
    _saveTraceSessions(_traceSessions);

    // トレース開始の確認ダイアログ
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('トレーシング開始'),
          content: Text('新しいトレーシングセッションを開始しました。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // トレース終了
  void _stopTracing() {
    if (_currentSession == null) {
      // トレースセッションが開始されていない場合
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('トレースセッションが開始されていません。')),
      );
      return;
    }

    setState(() {
      _currentSession!.endTime = DateTime.now();
      _currentSession = null;
    });

    // セッションを保存
    _saveTraceSessions(_traceSessions);

    // トレース終了の確認ダイアログ
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('トレーシング終了'),
          content: Text('現在のトレーシングセッションを終了しました。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // セッション内の写真データを編集
  Future<void> _editPhotoData(
      int sessionIndex, int photoIndex, PhotoData originalData) async {
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

      setState(() {
        _traceSessions[sessionIndex].photos[photoIndex] = newData;
      });

      // セッションを保存
      await _saveTraceSessions(_traceSessions);
    }
  }

  // 写真の削除確認
  Future<void> _confirmDelete(int sessionIndex, int photoIndex) async {
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
      setState(() {
        _traceSessions[sessionIndex].photos.removeAt(photoIndex);
      });
      _saveTraceSessions(_traceSessions);
    }
  }

  // トレースセッションのアップロード
  Future<void> _uploadImages() async {
    // ネットワーク接続を確認
    if (!(await _isConnectedToNetwork())) {
      // エラーダイアログを表示
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ネットワーク接続エラー'),
            content:
                Text('ネットワークに接続されていません。画像のアップロードは行えません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
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
          content: Text(
              '回線速度が安定した場所にいますか？安定している場合はアップロードを続行してください。'),
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

    // アップロード処理を並列で実行
    List<Future<void>> uploadFutures = [];

    for (int sessionIndex = 0; sessionIndex < _traceSessions.length; sessionIndex++) {
      TraceSession session = _traceSessions[sessionIndex];
      for (int photoIndex = 0; photoIndex < session.photos.length; photoIndex++) {
        PhotoData data = session.photos[photoIndex];
        if (data.uploadedFlag == 0) {
          uploadFutures.add(_uploadSingleImage(sessionIndex, photoIndex, data));
        }
      }
    }

    await Future.wait(uploadFutures);

    // セッションを保存
    await _saveTraceSessions(_traceSessions);

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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // 個別の画像をアップロードする関数
  Future<void> _uploadSingleImage(int sessionIndex, int photoIndex, PhotoData data) async {
    try {
      // 画像をアップロード
      String imageUrl = await _uploadImage(
        data.image,
        data.animalType,
        data.position,
        data.captureTime,
      );

      // Firebaseにデータを保存
      await _saveToFirestore(
        data.position,
        imageUrl,
        data.animalType,
        data.memo,
        data.elapsedForTrace,
        data.traceType,
        _selectedUserId,
        data.confidence,
        data.captureTime,
      );

      // uploadedFlagを1に更新
      setState(() {
        _traceSessions[sessionIndex].photos[photoIndex].uploadedFlag = 1;
      });
    } catch (e) {
      print('アップロード中にエラーが発生しました: $e');
      // エラー通知をユーザーに表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像のアップロード中にエラーが発生しました。')),
      );
    }
  }

  // ネットワーク接続を確認
  Future<bool> _isConnectedToNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // Firebase Firestoreにデータを保存
  Future<void> _saveToFirestore(
      Position position,
      String imageUrl,
      String animalType,
      String memo,
      String elapsedForTrace,
      String traceType,
      String selectedUserId,
      String confidence,
      DateTime captureTime) async {
    await _firestore.collection('wildlife_trace').add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'url': imageUrl,
      'timestamp': captureTime, // captureTimeを使用
      'AnimalType': animalType,
      'Memo': memo,
      'ElapsedForTrace': elapsedForTrace,
      'TraceType': traceType,
      'User_ID': selectedUserId,
      'Confidence': confidence,
    });
  }

  // 画像をFirebase Storageにアップロード
  Future<String> _uploadImage(
      File image, String animalType, Position position, DateTime captureTime) async {
    final storage = FirebaseStorage.instance;
    final folderPath = 'images/$animalType';

    // 撮影時の日時をファイル名として使用
    final String formattedTime = captureTime.toIso8601String().replaceAll(':', '-');
    final ref = storage.ref().child('$folderPath/$formattedTime.jpg');

    // メディアタイプをimage/jpegとして指定
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    // ファイルをアップロード（オリジナルの解像度を保持）
    await ref.putFile(image, metadata);

    // 画像のダウンロードURLを取得
    return await ref.getDownloadURL();
  }

  // 現在の位置を取得
  Future<Position> _getCurrentLocation() async {
    // 位置情報の許可を確認
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        throw Exception('位置情報の許可が必要です。');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

// 以下に専用ウィジェット ElapsedTimeWidget を追加
class ElapsedTimeWidget extends StatefulWidget {
  final DateTime startTime;

  ElapsedTimeWidget({required this.startTime});

  @override
  _ElapsedTimeWidgetState createState() => _ElapsedTimeWidgetState();
}

class _ElapsedTimeWidgetState extends State<ElapsedTimeWidget> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    // 初回更新を即時に行う
    _updateElapsedTime();
    // タイマーの更新間隔を毎分に設定
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateElapsedTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateElapsedTime() {
    setState(() {
      _elapsed = DateTime.now().difference(widget.startTime);
    });
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    return '$minutes分経過';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: Colors.white70,
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '調査開始から ${_formatDuration(_elapsed)}',
            style: TextStyle(
              fontSize: 16,
              fontFamily: "Noto Sans JP",
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
