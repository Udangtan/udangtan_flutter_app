import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:udangtan_flutter_app/app/env_config.dart';
import 'package:udangtan_flutter_app/models/user.dart' as app_user;
import 'package:udangtan_flutter_app/pages/auth/auth_page.dart';
import 'package:udangtan_flutter_app/pages/auth/login_page.dart';
import 'package:udangtan_flutter_app/pages/auth/register_page.dart';
import 'package:udangtan_flutter_app/pages/auth/register_success_page.dart';
import 'package:udangtan_flutter_app/pages/auth/reset_password_page.dart';
import 'package:udangtan_flutter_app/pages/main/main_navigation_page.dart';
import 'package:udangtan_flutter_app/pages/onboarding/onboarding_page.dart';
import 'package:udangtan_flutter_app/pages/onboarding/onboarding_success_page.dart';
import 'package:udangtan_flutter_app/pages/splash/splash_page.dart';
import 'package:udangtan_flutter_app/services/simple_deep_link_service.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();
  await SupabaseService.initialize();

  // 딥링크 서비스 초기화
  SimpleDeepLinkService.initialize();
  SimpleDeepLinkService.setNavigatorKey(navigatorKey);

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
      navigatorKey: navigatorKey,
      routes: {
        '/': (context) => const SplashPage(),
        '/welcome': (context) => const AuthPage(),
        '/register': (context) => const RegisterPage(),
        '/register-success': (context) => const RegisterSuccessPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainNavigation(),
        '/onboarding': (context) => const OnboardingPage(),
        '/onboarding-success': (context) => const OnboardingSuccessPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
      },
      builder: (context, child) {
        return AuthStateListener(child: child!);
      },
    );
  }
}

// Supabase Auth 상태를 전역적으로 감지하는 위젯
class AuthStateListener extends StatefulWidget {
  const AuthStateListener({super.key, required this.child});

  final Widget child;

  @override
  State<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    SupabaseService.client.auth.onAuthStateChange
        .listen((data) async {
          var event = data.event;
          var session = data.session;

          if (event == AuthChangeEvent.signedIn && session != null) {
            try {
              // 이메일 로그인 사용자 정보 처리
              var userId =
                  'email_${session.user.email?.replaceAll('@', '_').replaceAll('.', '_')}';

              // 기존 사용자 확인
              var existingUser = await SupabaseService.getUserById(userId);

              if (existingUser == null) {
                var newUser = app_user.User(
                  id: userId,
                  email: session.user.email ?? '$userId@example.com',
                  name: session.user.userMetadata?['name'] ?? '사용자',
                  profileImageUrl: '',
                  provider: 'email',
                );

                existingUser = await SupabaseService.createOrUpdateUser(
                  newUser,
                );
              }

              // 홈으로 이동 및 환영 메시지 표시
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);

                  // 환영 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('로그인 성공! 환영합니다! 🎉'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              });
            } catch (e) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('로그인 처리 중 오류가 발생했습니다: ${e.toString()}'),
                      backgroundColor: Colors.redAccent,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              });
            }
          } else if (event == AuthChangeEvent.signedOut) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/welcome', (route) => false);
              }
            });
          }
        })
        .onError((error) {
          // Supabase 인증 오류 처리 (딥링크 토큰 만료 등)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              String errorMessage = '인증 처리 중 오류가 발생했습니다.';

              if (error.toString().contains('otp_expired') ||
                  error.toString().contains('invalid or has expired')) {
                errorMessage = '🔗 인증 링크가 만료되었습니다.\n새로운 인증 이메일을 요청해주세요.';
              } else if (error.toString().contains('access_denied')) {
                errorMessage = '❌ 인증이 거부되었습니다.\n다시 시도해주세요.';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: '확인',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
