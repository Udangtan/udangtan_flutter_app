import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:udangtan_flutter_app/models/user.dart' as app_user;
import 'package:udangtan_flutter_app/services/supabase_service.dart';

class AuthService {
  static String _getErrorMessage(error) {
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid email':
        case 'email address is invalid':
          return '유효하지 않은 이메일 주소입니다.';
        case 'user already registered':
        case 'user already exists':
          return '이미 등록된 이메일 주소입니다.';
        case 'invalid login credentials':
        case 'invalid email or password':
          return '이메일 또는 비밀번호가 잘못되었습니다.';
        case 'password should be at least 6 characters':
          return '비밀번호는 최소 6자 이상이어야 합니다.';
        case 'signup is disabled':
          return '현재 회원가입이 비활성화되어 있습니다.';
        case 'email rate limit exceeded':
          return '이메일 발송 한도를 초과했습니다. 잠시 후 다시 시도해주세요.';
        case 'email link is invalid or has expired':
        case 'one-time token not found':
        case 'otp expired':
          return '인증 링크가 만료되었습니다. 새로운 인증 이메일을 요청해주세요.';
        case 'email not confirmed':
          return '이메일 인증이 완료되지 않았습니다.';
        default:
          return error.message;
      }
    }

    // Handle network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('HttpException')) {
      return '네트워크 연결을 확인해주세요.';
    }

    // Handle timeout errors
    if (error.toString().contains('TimeoutException')) {
      return '요청 시간이 초과되었습니다. 다시 시도해주세요.';
    }

    return '오류가 발생했습니다: ${error.toString()}';
  }

  static Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    String? name,
    BuildContext? context,
  }) async {
    try {
      // 이메일 형식 기본 검증
      if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(email)) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('올바른 이메일 형식을 입력해주세요.'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return null;
      }

      // 비밀번호 길이 검증
      if (password.length < 6) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('비밀번호는 최소 6자 이상이어야 합니다.'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return null;
      }

      var response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
        emailRedirectTo: 'udangtan://login-callback',
      );

      if (response.user != null && context != null && context.mounted) {
        // 이메일 확인이 필요한지 체크
        if (response.user!.emailConfirmedAt != null) {
          // 이메일 확인이 비활성화된 경우 (즉시 확인됨)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입이 완료되었습니다!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // 이메일 확인이 필요한 경우
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입이 완료되었습니다.\n이메일 인증을 완료해주세요.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }

      return response;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  static Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      // 이메일 형식 기본 검증
      if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(email)) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('올바른 이메일 형식을 입력해주세요.'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return null;
      }

      var response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 성공!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      return response;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  static Future<void> resetPassword({
    required String email,
    BuildContext? context,
  }) async {
    try {
      // 이메일 형식 기본 검증
      if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(email)) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('올바른 이메일 형식을 입력해주세요.'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      await SupabaseService.client.auth.resetPasswordForEmail(email);

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호 재설정 이메일을 발송했습니다.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      var session = SupabaseService.client.auth.currentSession;
      return session != null;
    } catch (error) {
      return false;
    }
  }

  static Future<Session?> getCurrentSession() async {
    try {
      return SupabaseService.client.auth.currentSession;
    } catch (error) {
      return null;
    }
  }

  static Future<app_user.User?> getCurrentUser() async {
    try {
      var session = SupabaseService.client.auth.currentSession;
      if (session == null) return null;

      // 실제 Supabase 사용자 UUID 사용
      var userId = session.user.id;
      return await SupabaseService.getUserById(userId);
    } catch (error) {
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (e) {
      // Handle error silently
    }
  }

  // 이메일 인증 재발송
  static Future<bool> resendConfirmationEmail({
    required String email,
    BuildContext? context,
  }) async {
    try {
      // 현재 사용자 세션 확인
      var currentUser = SupabaseService.client.auth.currentUser;
      if (currentUser == null) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('현재 로그인된 사용자가 없습니다. 다시 회원가입해주세요.'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return false;
      }

      // 이메일 재발송 시도
      await SupabaseService.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✉️ 인증 이메일을 다시 발송했습니다.\n$email로 확인해주세요.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return true;
    } catch (e) {
      var errorMessage = _getErrorMessage(e);

      // Rate limit 에러인 경우 특별히 처리
      if (e.toString().toLowerCase().contains('rate limit') ||
          e.toString().toLowerCase().contains('too many requests')) {
        errorMessage = '이메일 발송 한도를 초과했습니다.\n잠시 후(1-2분) 다시 시도해주세요.';
      }

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📧 이메일 재발송 실패\n$errorMessage'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '다시 시도',
              textColor: Colors.white,
              onPressed:
                  () => resendConfirmationEmail(email: email, context: context),
            ),
          ),
        );
      }
      return false;
    }
  }

  // 사용자 이메일 인증 상태 확인
  static bool isEmailConfirmed() {
    var user = SupabaseService.client.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  // 현재 사용자 이메일 가져오기
  static String? getCurrentUserEmail() {
    return SupabaseService.client.auth.currentUser?.email;
  }

  // 현재 사용자 UUID 가져오기 (주소 관리용)
  static String? getCurrentUserId() {
    return SupabaseService.client.auth.currentUser?.id;
  }
}
