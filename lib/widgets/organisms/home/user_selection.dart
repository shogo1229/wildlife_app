import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class userID_select extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserIdProvider(),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'IDを選択してください',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Consumer<UserIdProvider>(
                builder: (context, userIdProvider, child) {
                  return DropdownButton<int>(
                    value: userIdProvider.selectedUserId,
                    onChanged: (int? newValue) {
                      userIdProvider.updateUserId(newValue!);
                    },
                    items: [
                      ...List.generate(
                        10,
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text('User ID ${index + 1}'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserIdProvider with ChangeNotifier {
  int _selectedUserId = 1;

  int get selectedUserId => _selectedUserId;

  void updateUserId(int newUserId) {
    _selectedUserId = newUserId;
    notifyListeners();
  }
}
