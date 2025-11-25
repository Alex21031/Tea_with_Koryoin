import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  // 로그인 처리
  Future<void> login(String email, String password) async {
    try {
      _user = await _apiService.login(email, password);
      notifyListeners(); // 화면 갱신 알림
    } catch (e) {
      rethrow; // 에러를 UI로 넘김
    }
  }

  // 로그아웃
  void logout() {
    _user = null;
    notifyListeners();
  }

  // 회원가입 (상태 변경 없음, 통과만 시킴)
  Future<void> signup(String email, String username, String phone, String password) async {
    await _apiService.signup(email, username, phone, password);
  }
}