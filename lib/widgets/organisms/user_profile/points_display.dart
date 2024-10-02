import 'package:flutter/material.dart';

class PointsDisplay extends StatelessWidget {
  final Map<String, dynamic> userDocument;

  PointsDisplay({required this.userDocument});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTotalPointCard('痕跡発見数(全体)', userDocument['total_point']),
        _buildInfoCard('痕跡発見数(イノシシ)', userDocument['Boar_Point']),
        _buildInfoCard('痕跡発見数(ニホンジカ)', userDocument['Deer_Point']),
        _buildInfoCard('痕跡発見数(その他/不明)', userDocument['Other_Point']),
      ],
    );
  }

  Widget _buildTotalPointCard(String title, dynamic value) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.stars, color: Colors.orange), // アイコンはそのまま
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, dynamic value) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: _getImageForTitle(title), // タイトルに基づいた画像を表示
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
      ),
    );
  }

  Widget _getImageForTitle(String title) {
    switch (title) {
      case '痕跡発見数(イノシシ)':
        return Image.asset('lib/assets/images/Boar_pin_Normal.png', width: 40, height: 40);
      case '痕跡発見数(ニホンジカ)':
        return Image.asset('lib/assets/images/Deer_pin_Normal.png', width: 40, height: 40);
      case '痕跡発見数(その他/不明)':
        return Image.asset('lib/assets/images/Other_pin_Normal.png', width: 40, height: 40);
      default:
        return Image.asset('lib/assets/images/Other_pin_Normal.png', width: 40, height: 40);
    }
  }
}
