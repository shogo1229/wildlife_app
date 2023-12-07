import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/home/index.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
      ),
      body: Home(),
    );
  }
}
