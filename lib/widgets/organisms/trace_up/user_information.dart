// widgets/organisms/home/user_selection.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';
import 'package:wildlife_app/widgets/organisms/home/user_selection.dart';

class AnimalTypeMemoPage extends StatefulWidget {
  final File image;

  AnimalTypeMemoPage({required this.image});

  @override
  _AnimalTypeMemoPageState createState() => _AnimalTypeMemoPageState();
}

class _AnimalTypeMemoPageState extends State<AnimalTypeMemoPage> {
  String? _animalType; // 選択された動物の種類
  String? _traceType; // 選択された痕跡の種類
  TextEditingController _memoController =
      TextEditingController(); // メモのテキストエディティングコントローラ
  String? _selectedUserId; // 選択されたユーザーのID

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('痕跡の情報を選択してください'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 獣種（動物の種類）のボタン
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildAnimalTypeButton('lib/assets/images/Boar.png', 'Boar'),
                _buildAnimalTypeButton('lib/assets/images/Deer.png', 'Deer'),
                _buildAnimalTypeButton('lib/assets/images/Other.png', 'Other'),
              ],
            ),
            SizedBox(height: 16.0),

            // 痕跡の種類のボタン
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildTraceTypeButton('足跡', 'animal_footprint'),
                _buildTraceTypeButton('糞', 'animal_dropping'),
                _buildTraceTypeButton('樹皮剥ぎ跡', 'bark-stripping'),
                _buildTraceTypeButton('角こすり跡', 'horn-rubbing'),
                _buildTraceTypeButton('獣道', 'animal-trail'),
              ],
            ),
            SizedBox(height: 16.0),

            // 備考欄
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                labelText: '備考欄',
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),

            // 保存ボタン
            ElevatedButton(
              onPressed: () => _completeSelection(context),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // グレーの背景色
              ),
              child: Text(
                '保存',
                style: TextStyle(
                  color: Colors.white, // 白い文字色
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// 痕跡の種類ボタンを構築する関数
  Widget _buildTraceTypeButton(String label, String type) {
    return GestureDetector(
      onTap: () => _selectTraceType(type),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: _traceType == type
                ? Colors.red
                : Colors.grey, // Default color is gray
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
          color: _traceType == type
              ? Colors.grey.withOpacity(0.5)
              : Colors.transparent,
        ),
        margin: EdgeInsets.all(8.0),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

// 動物の種類ボタンを構築する関数
  Widget _buildAnimalTypeButton(String? imagePath, String type) {
    return GestureDetector(
      onTap: () => _selectAnimalType(type),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: _animalType == type
                ? Colors.red
                : Colors.grey, // Default color is gray
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
          color: _animalType == type
              ? Colors.grey.withOpacity(0.5)
              : Colors.transparent,
        ),
        margin: EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 動物の画像（もしあれば）
            imagePath != null
                ? Image.asset(
                    imagePath,
                    width: 80.0,
                    height: 80.0,
                    fit: BoxFit.cover,
                  )
                : Container(),
            SizedBox(height: 8.0),
            Text(
              type,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 動物の種類が選択されたときの処理
  void _selectAnimalType(String type) {
    setState(() {
      _animalType = type;
    });
  }

  // 痕跡の種類が選択されたときの処理
  void _selectTraceType(String type) {
    setState(() {
      _traceType = type;
    });
  }

  // 選択が完了しダイアログを閉じる処理
  void _completeSelection(BuildContext context) {
    _selectedUserId = context.read<UserProvider>().getUserId();
    Navigator.of(context).pop({
      'animalType': _animalType,
      'traceType': _traceType,
      'memo': _memoController.text,
      'selectedUserId': _selectedUserId,
    });
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
