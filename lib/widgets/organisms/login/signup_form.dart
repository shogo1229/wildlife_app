import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';
import 'package:wildlife_app/pages/home.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController _userNameController = TextEditingController();

  Future<void> _registerUser() async {
    try {
      // FirebaseAuthの初期化を確認
      await Firebase.initializeApp();

      // 認証されているユーザーを取得
      User? user = FirebaseAuth.instance.currentUser;
      print('ユーザーの取得に成功');
      if (user != null) {
        // ユーザーのUIDを取得
        String userUID = user.uid;

        // テキストコントローラーからユーザー名を取得
        String userName = _userNameController.text;

        // Firestoreのドキュメントへの参照
        var userDocRef = FirebaseFirestore.instance
            .collection('User_Information')
            .doc(userUID);

        // ドキュメントにデータを設定
        await userDocRef.set({
          'User_Name': userName,
          'User_ID': userUID,
          'Boar_Point': 0,
          'Deer_Point': 0,
          'Other_Point': 0,
          'total_point': 0,
        });

        // ホームページに遷移
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      print('ユーザー登録エラー: $e');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('エラー'),
            content: Text('ユーザー登録エラー: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // FirebaseAuthの初期化を確認
    Firebase.initializeApp();

    // ユーザープロバイダーからユーザーを取得
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザー登録'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ユーザー名の入力フィールド
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'ユーザー名'),
            ),

            // 他に必要な入力フィールドがあればここに追加できます。

            // 登録ボタン
            ElevatedButton(
              onPressed: () {
                print('登録ボタンの呼び出しには成功');
                _registerUser();
              },
              child: Text('登録'),
            ),
          ],
        ),
      ),
    );
  }
}
