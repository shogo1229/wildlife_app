import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';
import 'package:wildlife_app/pages/login.dart';

class GetUserName extends StatelessWidget {
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
    print(user?.uid);

    return Scaffold(
      body: StreamBuilder(
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
            print("---------------------------------------------------------");
            print(user?.uid);
            print("---------------------------------------------------------");
            return Center(
              child: Text('User not found'),
            );
          }

          var userDocument =
              snapshot.data?.docs.first.data() as Map<String, dynamic>;
          var userName = userDocument['User_Name'];

          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login User : $userName',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 16), // 適宜間隔を設定
                IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut(); // ログアウト
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.exit_to_app),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
