import 'package:flutter/material.dart';
import 'package:wildlife_app/pages/home.dart';
import '../../atoms/footerButton.dart';
import '../../../pages/ranking.dart';
import '../../../pages/user_profile.dart';
import '../../../pages/trace_up.dart';
import '../../../pages/trace_map.dart';

class UserProfileFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            NavigationButton(
              icon: '🏠',
              enabled: true,
              page: HomePage(), // Specify the page for '🏠'
            ),
            NavigationButton(
              icon: '📷',
              enabled: true,
              page: TraceUpPage(), // Specify the page for '📷'
            ),
            NavigationButton(
              icon: '🗾',
              enabled: true,
              page: TraceMapPage(), // Specify the page for '🗾'
            ),
            NavigationButton(
              icon: '🥇',
              enabled: true,
              page: RankingPage(), // Specify the page for '🥇'
            ),
            NavigationButton(
              icon: '👤',
              enabled: false,
              page: UserProfilePage(), // Specify the page for '👤'
            ),
          ],
        ),
      ),
    );
  }
}
