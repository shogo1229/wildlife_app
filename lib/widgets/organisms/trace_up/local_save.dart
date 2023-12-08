import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class PhotoData {
  File image;
  String imageUrl;
  String animalType;
  String memo;

  PhotoData({
    required this.image,
    required this.imageUrl,
    required this.animalType,
    required this.memo,
  });
}

class AnimalTypeMemoPage extends StatefulWidget {
  final File image;

  AnimalTypeMemoPage({required this.image});

  @override
  _AnimalTypeMemoPageState createState() => _AnimalTypeMemoPageState();
}

class _AnimalTypeMemoPageState extends State<AnimalTypeMemoPage> {
  String? _animalType;
  TextEditingController _memoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('見つけた痕跡の獣種を選択してください'),
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnimalTypeButton('lib/assets/images/Boar.png', 'Boar'),
              _buildAnimalTypeButton('lib/assets/images/Deer.png', 'Deer'),
            ],
          ),
          _buildAnimalTypeButton('lib/assets/images/Other.png', 'Other'),
          SizedBox(height: 16.0),
          TextField(
            controller: _memoController,
            decoration: InputDecoration(
                labelText: '備考欄',
                contentPadding: EdgeInsets.symmetric(vertical: 10.0)),
            maxLines: 5,
          ),
          ElevatedButton(
            onPressed: () => _completeSelection(),
            child: Text('保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalTypeButton(String? imagePath, String type) {
    return GestureDetector(
      onTap: () => _selectAnimalType(type),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _animalType == type ? Colors.red : Colors.transparent,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: imagePath != null
              ? Image.asset(
                  imagePath,
                  width: 80.0,
                  height: 80.0,
                  fit: BoxFit.cover,
                )
              : Text(
                  type,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  void _selectAnimalType(String type) {
    setState(() {
      _animalType = type;
    });
  }

  void _completeSelection() {
    Navigator.of(context)
        .pop({'animalType': _animalType, 'memo': _memoController.text});
  }
}

class Local_Camera extends StatefulWidget {
  @override
  _Local_CameraState createState() => _Local_CameraState();
}

class _Local_CameraState extends State<Local_Camera> {
  static List<PhotoData> _images = [];
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return GridTile(
                  child: Image.file(_images[index].image),
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

  Future<void> _takePicture() async {
    final imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      _showAnimalTypeMemoDialog(File(imageFile.path));
    }
  }

  Future<void> _showAnimalTypeMemoDialog(File image) async {
    Map<String, dynamic>? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimalTypeMemoPage(image: image);
      },
    );

    if (result != null) {
      String animalType = result['animalType'];
      String memo = result['memo'];

      setState(() {
        _images.add(PhotoData(
          image: image,
          imageUrl: '',
          animalType: animalType,
          memo: memo,
        ));
      });
    }
  }

  Future<void> _uploadImages() async {
    if (!(await _isConnectedToNetwork())) {
      // Device is not connected to the network, show an error message or take appropriate action.
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
        Position position = await _getCurrentLocation();
        data.imageUrl = await _uploadImage(data.image);
        await _saveToFirestore(
            position, data.imageUrl, data.animalType, data.memo);
        setState(() {
          _images.remove(data);
        });
      } catch (e) {
        print('画像のアップロード中にエラーが発生しました： $e');
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

  Future<String> _uploadImage(File image) async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('images/${DateTime.now()}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _saveToFirestore(Position position, String imageUrl,
      String animalType, String memo) async {
    await _firestore.collection('wildlife_trace').add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'url': imageUrl,
      'timestamp': DateTime.now(),
      'AnimalType': animalType,
      'Memo': memo,
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