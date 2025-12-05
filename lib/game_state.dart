import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameState extends ChangeNotifier {
  int _unlockedLevels = 1;
  int _coins = 0;
  User? _user;

  int get unlockedLevels => _unlockedLevels;
  int get coins => _coins;
  User? get user => _user;
  String? get userEmail => _user?.email;
  String? get userPhotoUrl => _user?.photoURL;

  bool get isLoggedIn => _user != null;

  void setUser(User? user) {
    print('GameState.setUser called with user: ${user?.email}, isLoggedIn: ${user != null}');
    _user = user;
    notifyListeners();
  }

  void setUnlockedLevels(int levels) {
    if (_unlockedLevels < levels) {
      _unlockedLevels = levels;
      notifyListeners();
    }
  }

  void addCoins(int amount) {
    _coins += amount;
    notifyListeners();
  }

  void spendCoins(int amount) {
    _coins -= amount;
    notifyListeners();
  }

  void fromJson(Map<String, dynamic> json) {
    _unlockedLevels = json['unlockedLevels'] ?? 1;
    _coins = json['coins'] ?? 0;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'unlockedLevels': _unlockedLevels,
      'coins': _coins,
    };
  }

  void reset() {
    _user = null;
    _unlockedLevels = 1;
    _coins = 0;
    notifyListeners();
  }
}
