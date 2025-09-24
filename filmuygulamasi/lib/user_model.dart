import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String _id = '';
  String _email = '';

  String get id => _id;
  String get email => _email;

  void setUser(String id, String email) {
    _id = id;
    _email = email;
    notifyListeners(); // User data değiştiğinde UI'yı güncellemek için.
  }

  void clearUser() {
    _id = '';
    _email = '';
    notifyListeners();
  }
}
