import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _submit() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signup(
        _emailCtrl.text, _userCtrl.text, _phoneCtrl.text, _passCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('회원가입 성공! 로그인해주세요.')));
      Navigator.pop(context); // 로그인 화면으로 복귀
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: '이메일')),
            TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: '사용자명')),
            TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: '전화번호')),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: '비밀번호'), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit, 
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('가입하기')
            ),
          ],
        ),
      ),
    );
  }
}