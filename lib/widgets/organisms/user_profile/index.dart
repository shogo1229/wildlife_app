import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/user_profile/footer.dart';
import 'package:wildlife_app/widgets/organisms/user_profile/network.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 9, // adjust the flex values as needed
          child: NetworkStatusWidget(),
        ),
        Expanded(
          flex: 1, // adjust the flex values as needed
          child: UserProfileFooter(),
        ),
      ],
    );
  }
}
