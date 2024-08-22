import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/user_profile/footer.dart';
//import 'package:wildlife_app/widgets/organisms/user_profile/network.dart';
import 'package:wildlife_app/widgets/organisms/user_profile/user_information.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // これを追加
      children: <Widget>[
        Expanded(
          flex: 8, // adjust the flex values as needed
          child: UserInformationMenus(),
        ),
        Expanded(
          flex: 1, // adjust the flex values as needed
          child: UserProfileFooter(),
        ),
      ],
    );
  }
}
