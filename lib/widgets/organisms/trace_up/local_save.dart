import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';
import 'package:wildlife_app/widgets/organisms/home/user_selection.dart';

class PhotoData {
  File image;
  String imageUrl;
  String animalType;
  String memo;
  Position position;
  String traceType;

  PhotoData({
    required this.image,
    required this.imageUrl,
    required this.animalType,
    required this.memo,
    required this.position,
    required this.traceType,
  });
}

class AnimalTypeMemoWizard extends StatefulWidget {
  final File image;

  AnimalTypeMemoWizard({required this.image});

  @override
  _AnimalTypeMemoWizardState createState() => _AnimalTypeMemoWizardState();
}

class _AnimalTypeMemoWizardState extends State<AnimalTypeMemoWizard> {
  int _currentStep = 0;
  String? _animalType;
  String? _traceType;
  TextEditingController _memoController = TextEditingController();

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _completeSelection(BuildContext context) {
    Navigator.of(context).pop({
      'animalType': _animalType,
      'traceType': _traceType,
      'memo': _memoController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('痕跡の情報を入力'),
        backgroundColor: Colors.green[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/bg_image.png'), // 背景画像を指定
            fit: BoxFit.cover, // 画面全体にフィットさせる
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _buildCurrentStep(),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildAnimalTypeSelection();
      case 1:
        return _buildTraceTypeSelection();
      case 2:
        return _buildMemoInput();
      default:
        return Container();
    }
  }

  Widget _buildAnimalTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '動物の種類を選択してください',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 20.0,
              runSpacing: 20.0,
              children: [
                _buildAnimalTypeButton('lib/assets/images/Boar.png', 'Boar'),
                _buildAnimalTypeButton('lib/assets/images/Deer.png', 'Deer'),
                _buildAnimalTypeButton('lib/assets/images/Other.png', 'Other'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTraceTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '痕跡の種類を選択してください',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 20.0,
              runSpacing: 20.0,
              children: [
                _buildTraceTypeButton('足跡', 'animal_footprint', Icons.pets),
                _buildTraceTypeButton('糞', 'animal_dropping', Icons.delete),
                _buildTraceTypeButton('樹皮剥ぎ跡', 'bark-stripping', Icons.park),
                _buildTraceTypeButton('角こすり跡', 'horn-rubbing', Icons.handyman),
                _buildTraceTypeButton('獣道', 'animal-trail', Icons.terrain),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '備考を入力してください',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: TextField(
            controller: _memoController,
            decoration: InputDecoration(
              labelText: '備考',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: EdgeInsets.all(16.0),
            ),
            maxLines: null,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalTypeButton(String imagePath, String type) {
    return GestureDetector(
      onTap: () => setState(() {
        _animalType = type;
      }),
      child: Container(
        width: 120.0,
        height: 140.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: _animalType == type ? Colors.green[800]! : Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(16.0),
          color: _animalType == type
              ? Colors.green[100]
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 60.0,
              height: 60.0,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8.0),
            Text(
              type,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: _animalType == type ? Colors.green[800] : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraceTypeButton(String label, String type, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() {
        _traceType = type;
      }),
      child: Container(
        width: 120.0,
        height: 120.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: _traceType == type ? Colors.green[800]! : Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(16.0),
          color: _traceType == type
              ? Colors.green[100]
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.0,
              color: _traceType == type ? Colors.green[800] : Colors.black,
            ),
            SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: _traceType == type ? Colors.green[800] : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_currentStep > 0)
          ElevatedButton(
            onPressed: _previousStep,
            child: Text('前へ'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              textStyle: TextStyle(
                fontSize: 30.0,
              ),
              primary: Colors.green[900], // 背景色
              onPrimary: Colors.white,        // テキスト色
            ),
          ),
        ElevatedButton(
          onPressed: _currentStep < 2 ? _nextStep : () => _completeSelection(context),
          child: Text(_currentStep < 2 ? '次へ' : '完了'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            textStyle: TextStyle(
              fontSize: 30.0,
            ),
            primary: Colors.green[900], // 背景色
            onPrimary: Colors.white,        // テキスト色
          ),
        ),
      ],
    );
  }
}

// ローカルカメラ機能を担当するメインページの Stateful Widget
class Local_Camera extends StatefulWidget {
  @override
  _Local_CameraState createState() => _Local_CameraState();
}

// Local_Cameraの State クラス
class _Local_CameraState extends State<Local_Camera> {
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/bg_image.png'), // 背景画像を指定
            fit: BoxFit.cover, // 画面全体にフィットさせる
          ),
        ),
        child: Column(
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
                  return Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.file(
                              _images[index].image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Row(
                            children: [
                              Icon(Icons.pets), // Add animal icon
                              SizedBox(width: 4.0),
                              Text(
                                '獣種: ${getAnimalType(_images[index].animalType)}',
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pets), // Add trace icon
                                  SizedBox(width: 4.0),
                                  Text(
                                    '痕跡種: ${getTraceType(_images[index].traceType)}',
                                    style: TextStyle(fontSize: 10.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                  child: Row(
                    children: [
                      Icon(Icons.camera), // Add camera icon
                      SizedBox(
                          width: 8), // Add some space between the icon and text
                      Text('痕跡を撮影'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _uploadImages,
                  child: Row(
                    children: [
                      Icon(Icons.upload), // Add upload icon
                      SizedBox(
                          width: 8), // Add some space between the icon and text
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

  // 写真を撮影し AnimalTypeMemoWizard を表示する関数
  Future<void> _takePicture() async {
    final imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      Position position = await _getCurrentLocation();
      _showAnimalTypeMemoDialog(File(imageFile.path), position);
    }
  }

  // AnimalTypeMemoWizard ダイアログを表示する関数
  Future<void> _showAnimalTypeMemoDialog(File image, Position position) async {
    Map<String, dynamic>? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimalTypeMemoWizard(image: image);
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

// アップロード進捗を表示する Stateful Widget
class UploadProgressModal extends StatefulWidget {
  final String message;

  UploadProgressModal({required this.message});

  @override
  _UploadProgressModalState createState() => _UploadProgressModalState();
}

// UploadProgressModalの State クラス
class _UploadProgressModalState extends State<UploadProgressModal> {
  @override
  Widget build(BuildContext context) {
    // アップロード進捗を表示する UI
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16.0),
          Text(widget.message),
        ],
      ),
    );
  }
}
