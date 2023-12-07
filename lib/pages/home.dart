import 'package:flutter/material.dart';
import '../widgets/organisms/home/home.dart';

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
