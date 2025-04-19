import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('홈1221')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [Text('여기에 반려동물 리스트가 들어갈 예2정')],
      ),
    );
  }
}
