import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  double _imageOpacity = 0.0;
  double _secondImageOpacity = 0.0;
  bool _showText1 = false;
  bool _showText2 = false;
  bool _showText3 = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() {
      _showText1 = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _showText2 = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _showText3 = true;
    });

    if (!mounted) return;
    setState(() {
      _imageOpacity = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _secondImageOpacity = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    if (context.mounted) {
      await Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 텍스트들 (순차 Fade)
            AnimatedOpacity(
              opacity: _showText1 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: const Text(
                '친구찾기',
                style: TextStyle(fontSize: 22, color: Color(0xFF999999)),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: _showText2 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: const Text(
                '이제 반려동물도 시작해요',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: _showText3 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: const Text(
                '오늘부터 PetFriend',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),

            /// 이미지 1 → 이미지 2 전환
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _imageOpacity,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/images/splash-image.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                AnimatedOpacity(
                  opacity: _secondImageOpacity,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/images/splash-image2.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
