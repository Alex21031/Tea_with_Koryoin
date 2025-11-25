import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: user == null 
        ? const Center(child: Text('로그인 정보가 없습니다.'))
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_circle, size: 100, color: Colors.grey),
                const SizedBox(height: 20),
                Text('사용자명: ${user.username}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('이메일: ${user.email}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('전화번호: ${user.phone}', style: const TextStyle(fontSize: 18)),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 여기에 정보 수정 페이지 이동 로직 추가 가능
                    },
                    child: const Text('정보 수정'),
                  ),
                )
              ],
            ),
          ),
    );
  }
}