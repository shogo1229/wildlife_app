import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';
import 'package:wildlife_app/widgets/molecules/user_profile/footer.dart';
import 'package:wildlife_app/widgets/organisms/user_profile/points_display.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart'; // 追加
import 'package:wildlife_app/widgets/organisms/trace_up/trace_session.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/photo_data.dart';

class UserInformationMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserInformationMenus(),
    );
  }
}

class UserInformationMenus extends StatefulWidget {
  @override
  _UserInformationMenusState createState() => _UserInformationMenusState();
}

class _UserInformationMenusState extends State<UserInformationMenus> {
  List<TraceSession> _uploadedSessions = [];

  @override
  void initState() {
    super.initState();
    _loadUploadedSessions();
  }

  Future<void> _loadUploadedSessions() async {
    List<TraceSession> sessions = await _loadTraceSessions();
    setState(() {
      // 投稿済みの痕跡を含むセッションのみを表示
      _uploadedSessions = sessions
          .where((session) =>
              session.photos.any((photo) => photo.uploadedFlag == 1))
          .toList();
    });
  }

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
                          // カードの上にお名前を表示
                          Text(
                            'お名前',
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: "Noto Sans JP",
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildUserNameCard(context, userDocument['User_Name']),
                          SizedBox(height: 16),
                          PointsDisplay(userDocument: userDocument), // 新しいウィジェットを使用
                          SizedBox(height: 24),
                          _buildUploadedTracesSection(),
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

  Widget _buildUploadedTracesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '投稿済みの痕跡一覧',
          style: TextStyle(
            fontSize: 22,
            fontFamily: "Noto Sans JP",
          ),
        ),
        SizedBox(height: 16),
        _uploadedSessions.isEmpty
            ? Text('投稿済みの痕跡がありません')
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _uploadedSessions.length,
                itemBuilder: (context, sessionIndex) {
                  final session = _uploadedSessions[sessionIndex];
                  return Card(
                    color: Colors.white,
                    elevation: 4.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: session.photos.length,
                          itemBuilder: (context, photoIndex) {
                            final photo = session.photos[photoIndex];
                            if (photo.uploadedFlag == 1) {
                              return ListTile(
                                leading: Image.file(
                                  photo.image,
                                  width: 50.0,
                                  height: 50.0,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                    '獣種: ${getAnimalType(photo.animalType)}'),
                                subtitle: Text(
                                    '痕跡種: ${getTraceType(photo.traceType)}'),
                                trailing: Text('投稿済み'),
                              );
                            } else {
                              return Container(); // 未投稿の痕跡は表示しない
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildUserNameCard(BuildContext context, String userName) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
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
