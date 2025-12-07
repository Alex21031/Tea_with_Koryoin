import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../models/chat_model.dart';

class ChatRoomScreen extends StatefulWidget {
  final int roomId;
  final String otherName;
  final int otherId;

  const ChatRoomScreen({super.key, required this.roomId, required this.otherName, required this.otherId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  List<ChatMessage> _messages = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) => _loadMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _loadMessages() async {
    try {
      final msgs = await _apiService.getMessages(widget.roomId);
      
      // 새 메시지가 왔을 때만 스크롤 내리기 (간단 구현)
      bool shouldScroll = false;
      if (_messages.length != msgs.length) shouldScroll = true;

      if (mounted) {
        setState(() {
          _messages = msgs;
        });
        if (shouldScroll) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollCtrl.hasClients) {
              _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
            }
          });
        }
      }
    } catch (e) {
      print('메시지 로드 오류: $e');
    }
  }

  void _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    
    final myUser = Provider.of<AuthProvider>(context, listen: false).user;
    if (myUser == null) return;

    _msgCtrl.clear();
    try {
      await _apiService.sendMessage(widget.roomId, int.parse(myUser.id), text);
      _loadMessages(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('전송 실패')));
    }
  }

  // 시간 포맷 (예: 14:30)
  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUser = Provider.of<AuthProvider>(context).user;
    final myId = myUser != null ? int.parse(myUser.id) : 0;

    return Scaffold(
      // ✅ 배경색을 연한 베이지색으로 변경 (따뜻한 느낌)
      backgroundColor: const Color(0xFFF5F2F0), 
      appBar: AppBar(
        title: Text(widget.otherName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.senderId == myId;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 상대방 말풍선일 때 시간 표시 (오른쪽)
                      if (isMe) ...[
                        Text(
                          _formatTime(msg.createdAt),
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // 말풍선 디자인
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            // ✅ 내 메시지: 진한 갈색, 상대 메시지: 흰색
                            color: isMe ? const Color(0xFF5D4037) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 3, offset: const Offset(0, 1))
                            ]
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      // 내 말풍선일 때 시간 표시 (왼쪽)
                      if (!isMe) ...[
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(msg.createdAt),
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          
          // ✅ 입력창 디자인 개선
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: const InputDecoration(
                          hintText: '메시지 보내기...',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5D4037), // 전송 버튼 (브랜드 컬러)
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}