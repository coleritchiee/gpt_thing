import 'package:flutter/material.dart';
import 'models.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void signIn(User user){
    _currentUser = user;
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}