import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/user_profile/index.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザ情報'),
      ),
      body: UserProfile(),
    );
  }
}
