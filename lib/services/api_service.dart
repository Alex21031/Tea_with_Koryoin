import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/post.dart';

class ApiService {
  // 안드로이드 에뮬레이터용 주소. iOS 시뮬레이터라면 'http://localhost:8080' 사용
  static const String baseUrl = 'http://10.0.2.2:8080';

  // 헤더 생성 도우미
  Map<String, String> _headers({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token'; // 토큰 인증 방식일 경우 (현재 서버 로직에 따라 조정 가능)
    }
    return headers;
  }

  // 로그인
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user'], token: data['token']);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  // 회원가입
  Future<void> signup(String email, String username, String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'username': username,
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  // 게시물 목록 조회
  Future<List<Post>> getPosts(int page) async {
    final response = await http.get(Uri.parse('$baseUrl/posts?page=$page'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> postsJson = data['posts'];
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('게시물을 불러오지 못했습니다.');
    }
  }

  // 게시물 작성
  Future<void> createPost(int userId, String title, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/create'),
      headers: _headers(),
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }
}