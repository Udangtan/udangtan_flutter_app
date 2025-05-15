import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:udangtan_flutter_app/pages/auth/authPage.dart';
import 'package:udangtan_flutter_app/pages/auth/login.dart';
import 'package:udangtan_flutter_app/pages/auth/registerPage.dart';
import 'package:udangtan_flutter_app/pages/auth/registerSuccessPage.dart';
import 'package:udangtan_flutter_app/pages/home/homePage.dart';
import 'package:udangtan_flutter_app/pages/splash/splashPage.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
  // await Future.delayed(const Duration(milliseconds: 2000), () {
  //   if (kDebugMode) {
  //     print('success');
  //   }
  //   FlutterNativeSplash.remove();
  // });
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
        '/home': (context) => const HomePage(),
      },

      //home: Scaffold(
      //  appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      //  body: Center(
      //    child: Image.asset(
      //      'assets/images/splash-image.png',
      //      width: 200, // 원하는 크기로 설정 가능
      //      height: 200,
      //      fit: BoxFit.contain,
      //    ),
      //  ),
      //),
    );
  }
}
