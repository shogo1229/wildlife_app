import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/user_profile/user_profile.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UserProfilePage'),
      ),
      body: UserProfile(),
    );
  }
}
