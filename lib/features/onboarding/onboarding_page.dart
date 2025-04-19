import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();

    return Scaffold(
      body: PageView(
        controller: controller,
        children: const [
          OnboardingContent(
            title: '친구 찾기,\n이제 반려동물도 시작해요',
            highlight: '오늘부터 PetFriend',
            imagePath: 'assets/image/boading_dog.png',
            buttonText: '펫친구 시작하기',
            nextRoute: '/home',
          ),
          OnboardingContent(
            title: '함께 산책할 친구를\n찾아보세요',
            highlight: '이제 PetFriend로 연결해요',
            imagePath: 'assets/image/boading_dog.png',
            buttonText: '시작하기',
            nextRoute: '/home',
          ),
        ],
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title;
  final String highlight;
  final String imagePath;
  final String buttonText;
  final String nextRoute;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.highlight,
    required this.imagePath,
    required this.buttonText,
    required this.nextRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                highlight,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9B51E0),
                ),
              ),
            ],
          ),
          Image.asset(imagePath, height: 220),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B51E0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                context.go(nextRoute);
              },
              child: Text(
                buttonText,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
