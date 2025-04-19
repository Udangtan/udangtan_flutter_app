import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('반려동물 매칭 앱', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              TextButton(
                child: Text("카카오 로그인"),
                onPressed: () {
                  // 일단 기능 없이 홈으로 이동
                  Navigator.of(context).pushNamed('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
