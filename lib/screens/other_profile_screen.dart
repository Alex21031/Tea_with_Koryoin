import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'chat_room_screen.dart';

class OtherProfileScreen extends StatefulWidget {
  final int userId;

  const OtherProfileScreen({super.key, required this.userId});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    try {
      final user = await _apiService.getUserProfile(widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _startChat() async {
    final myUser = Provider.of<AuthProvider>(context, listen: false).user;
    if (myUser == null || _user == null) return;

    try {
      int roomId = await _apiService.createChatRoom(int.parse(myUser.id), int.parse(_user!.id));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            roomId: roomId, 
            otherName: _user!.name,
            otherId: int.parse(_user!.id),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('채팅 시작 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null) return const Scaffold(body: Center(child: Text('사용자 정보를 찾을 수 없습니다.')));

    final bool isExpert = _user!.role == 'expert';

    return Scaffold(
      appBar: AppBar(title: const Text('프로필'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 20),
            
            // 이름
            Text(_user!.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            
            // 역할 (전문가/일반)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isExpert ? Colors.orangeAccent.withOpacity(0.2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isExpert ? '전문가 회원' : '일반 회원',
                style: TextStyle(
                  color: isExpert ? Colors.orange[800] : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            const SizedBox(height: 20),
            
            const SizedBox(height: 30),

            // ✅ [추가됨] 전문가일 경우 이메일 표시
            if (isExpert) 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Column(
                  children: [
                    const Text('문의용 이메일', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    const SizedBox(height: 4),
                    Text(
                      _user!.email, // User 모델에 있는 email 필드 사용
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),

            // 채팅하기 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _startChat,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('1:1 채팅하기'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}