import 'package:flutter/material.dart';
import 'package:wildlife_app/pages/home.dart';
import '../../../pages/user_profile.dart';
import '../../../pages/trace_up.dart';

class HomeFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Divider(color: Colors.grey), // 灰色の線を削除
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                NavigationButton(
                  icon: Icons.home,
                  label: 'ホーム',
                  enabled: false,
                  page: HomePage(), // Specify the page for 'home'
                ),
                NavigationButton(
                  icon: Icons.camera_alt,
                  label: '撮影',
                  enabled: true,
                  page: TraceUpPage(), // Specify the page for 'camera'
                ),
                NavigationButton(
                  icon: Icons.person,
                  label: 'ユーザ',
                  enabled: true,
                  page: UserProfilePage(), // Specify the page for 'profile'
                ),
              ],
            ),
          ),
          SizedBox(height: 8), // 少しの余白を追加
        ],
      ),
    );
  }
}

class NavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final Widget page;

  NavigationButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(icon, color: enabled ? Colors.grey : Colors.green[800]),
          onPressed: enabled
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                }
              : null,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: enabled ? Colors.grey : Colors.green[800],
          ),
        ),
      ],
    );
  }
}
