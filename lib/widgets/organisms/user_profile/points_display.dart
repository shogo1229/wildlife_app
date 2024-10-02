import 'package:flutter/material.dart';

class PointsDisplay extends StatelessWidget {
  final Map<String, dynamic> userDocument;

  PointsDisplay({required this.userDocument});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 見出し
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '痕跡発見数',
            style: TextStyle(
              fontSize: 22,
              fontFamily: "Noto Sans JP",
            ),
          ),
        ),
        // 2x2のカードレイアウト
        _buildHorizontalInfoCards(),
      ],
    );
  }

  Widget _buildHorizontalInfoCards() {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(child: _buildInfoCard('全体', userDocument['total_point'], Icons.stars)),
            SizedBox(width: 8),
            Expanded(child: _buildInfoCard('イノシシ', userDocument['Boar_Point'], 'lib/assets/images/Boar_pin_Normal.png')),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(child: _buildInfoCard('ニホンジカ', userDocument['Deer_Point'], 'lib/assets/images/Deer_pin_Normal.png')),
            SizedBox(width: 8),
            Expanded(child: _buildInfoCard('その他', userDocument['Other_Point'], 'lib/assets/images/Other_pin_Normal.png')),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, dynamic value, dynamic iconOrImage) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 名称 (改行)
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: "Noto Sans JP",),
            ),
            SizedBox(height: 8),
            // 画像またはアイコンとポイントを横並びに表示
            Row(
              children: <Widget>[
                _getIconOrImage(iconOrImage),
                SizedBox(width: 20), // アイコン/画像とポイントの間にスペース
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // アイコンか画像かを動的に返す
  Widget _getIconOrImage(dynamic iconOrImage) {
    if (iconOrImage is IconData) {
      return Icon(iconOrImage, color: Colors.orange, size: 40);
    } else if (iconOrImage is String) {
      return Image.asset(iconOrImage, width: 40, height: 40);
    } else {
      return SizedBox.shrink(); // 何も表示しない
    }
  }
}
