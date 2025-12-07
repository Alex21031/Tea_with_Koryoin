import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../models/chat_model.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null) return const Center(child: Text('로그인이 필요합니다.'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<ChatRoom>>(
        future: _apiService.getMyChatRooms(int.parse(user.id)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('대화방이 없습니다.\n전문가 프로필에서 채팅을 시작해보세요!', 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final rooms = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: rooms.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[100]),
            itemBuilder: (ctx, idx) {
              final room = rooms[idx];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatRoomScreen(
                        roomId: room.id, 
                        otherName: room.otherName, 
                        otherId: room.otherId
                      ),
                    ),
                  ).then((_) => setState((){})); 
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.brown[50], // 연한 갈색 배경
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            room.otherName.isNotEmpty ? room.otherName[0] : '?',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[400]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 이름 및 미리보기
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.otherName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '대화를 이어서 하려면 터치하세요.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[300]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}