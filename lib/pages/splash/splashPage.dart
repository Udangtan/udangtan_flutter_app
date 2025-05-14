import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _opacity = 0.0;
  bool _showText = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashAnimation();
    });
  }

  Future<void> _startSplashAnimation() async {
    FlutterNativeSplash.remove();

    // fade-in 시작
    setState(() {
      _opacity = 1.0;
    });

    // 2초 동안 이미지 fade-in
    await Future.delayed(const Duration(seconds: 2));

    // 이미지 fully visible 된 후 텍스트 보여주기
    setState(() {
      _showText = true;
    });

    // 전체 splash 시간은 약 5초 → 3초 더 기다리고 다음 화면으로 이동
    await Future.delayed(const Duration(seconds: 3));

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // HTML splash와 동일한 배경
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/splash-image.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  // const CircularProgressIndicator(color: Colors.deepPurple), // 로딩바
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 텍스트는 이미지 fully shown 후 표시
            if (_showText)
              const Text(
                '오늘부터 PetFriend',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
