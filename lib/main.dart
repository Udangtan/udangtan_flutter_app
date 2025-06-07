import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'package:udangtan_flutter_app/pages/auth/auth_page.dart';
import 'package:udangtan_flutter_app/pages/auth/login.dart';
import 'package:udangtan_flutter_app/pages/auth/register_page.dart';
import 'package:udangtan_flutter_app/pages/auth/register_success_page.dart';
import 'package:udangtan_flutter_app/pages/main/main_navigation.dart';
import 'package:udangtan_flutter_app/pages/onboarding/onboarding_page.dart';
import 'package:udangtan_flutter_app/pages/onboarding/onboarding_success_page.dart';
import 'package:udangtan_flutter_app/pages/splash/splash_page.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  AuthRepository.initialize(appKey: '4a0bbde82e8b37e4ed3a3f3c0255852b');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetFriend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/welcome': (context) => const AuthPage(),
        '/register': (context) => const RegisterPage(),
        '/register-success': (context) => const RegisterSuccessPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainNavigation(),
        '/onboarding': (context) => const OnboardingPage(),
        '/onboarding-success': (context) => const OnboardingSuccessPage(),
      },
    );
  }
}
