import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udangtan_flutter_app/pages/auth/reset_password_page.dart';

class SimpleDeepLinkService {
  static const MethodChannel _channel = MethodChannel('simple_deep_link');
  static GlobalKey<NavigatorState>? _navigatorKey;

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'deepLinkReceived') {
        String? deepLink = call.arguments;
        if (deepLink != null) {
          await _handleDeepLink(deepLink);
        }
      }
    });
  }

  static Future<void> _handleDeepLink(String deepLink) async {
    try {
      var uri = Uri.parse(deepLink);

      // 비밀번호 초기화 딥링크 처리 (login-callback이 host로 들어옴)
      if (uri.host == 'login-callback' ||
          uri.path.contains('login-callback') ||
          deepLink.contains('login-callback')) {
        var code = uri.queryParameters['code'];
        if (code != null) {
          // Navigator context가 준비될 때까지 대기
          await Future.delayed(const Duration(milliseconds: 500));

          // BuildContext를 다시 확인하여 async gap 문제 해결
          var navigatorState = _navigatorKey?.currentState;
          if (navigatorState != null && navigatorState.mounted) {
            // 비밀번호 변경 페이지로 이동
            await navigatorState.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(code: code),
              ),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      // 딥링크 처리 오류 발생 시 조용히 무시
    }
  }

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  static void testDeepLink(String testUrl) {
    _handleDeepLink(testUrl);
  }
}
