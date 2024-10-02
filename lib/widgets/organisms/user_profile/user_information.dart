import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';
import 'package:wildlife_app/widgets/molecules/user_profile/footer.dart';
import 'package:wildlife_app/widgets/organisms/user_profile/points_display.dart'; 

class UserInformationMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserInformationMenus(),
    );
  }
}

class UserInformationMenus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).getUser();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/bg_image.png'), // 背景画像のパス
            fit: BoxFit.cover, // 画像が画面全体をカバーするように設定
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('User_Information')
                    .where('User_ID', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                    return Center(
                      child: Text('User not found'),
                    );
                  }

                  var userDocument =
                      snapshot.data?.docs.first.data() as Map<String, dynamic>;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildUserNameCard(context, userDocument['User_Name']),
                          SizedBox(height: 16),
                          PointsDisplay(userDocument: userDocument), // 新しいウィジェットを使用
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserNameCard(BuildContext context, String userName) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          'お名前',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          userName,
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.green[800]),
          onPressed: () => _showEditNameDialog(context, userName),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ユーザ名を変更します'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: '新しいユーザー名を入力してください'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('保存'),
              onPressed: () async {
                String newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  await _updateUserName(newName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserName(String newName) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('User_Information')
          .doc(user.uid)
          .update({'User_Name': newName});
    }
  }
}
