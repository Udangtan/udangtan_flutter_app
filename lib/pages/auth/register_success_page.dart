import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udangtan_flutter_app/app/env_config.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';

class RegisterSuccessPage extends StatefulWidget {
  const RegisterSuccessPage({super.key});

  @override
  State<RegisterSuccessPage> createState() => _RegisterSuccessPageState();
}

class _RegisterSuccessPageState extends State<RegisterSuccessPage> {
  bool _isCheckingAuth = false;
  bool _isResending = false;
  int _resendAttempts = 0;
  DateTime? _lastResendTime;

  @override
  void initState() {
    super.initState();
    // Supabase 설정 확인
    _checkSupabaseConfig();
    // 주기적으로 인증 상태 확인
    _startAuthCheck();
  }

  void _checkSupabaseConfig() {
    // Supabase URL과 Key가 설정되어 있는지 확인
    if (EnvConfig.supabaseUrl.isEmpty || EnvConfig.supabaseAnonKey.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Supabase 설정이 필요합니다.\n.env 파일을 확인해주세요.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      });
    } else {
      // Supabase 설정이 완료된 경우에만 인증 체크 시작
    }
  }

  void _startAuthCheck() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _checkAuthStatus();
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;

    setState(() => _isCheckingAuth = true);

    try {
      // Supabase 연결 상태 확인
      if (SupabaseService.client.auth.currentSession == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인 세션이 없습니다. 다시 로그인해주세요.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // 세션 새로고침
      await SupabaseService.client.auth.refreshSession();

      if (AuthService.isEmailConfirmed()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이메일 인증이 완료되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
          await Navigator.pushReplacementNamed(context, '/home');
        }
        return;
      }

      // 인증이 아직 완료되지 않은 경우
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이메일 인증이 아직 완료되지 않았습니다.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );

        // 5초 후 다시 확인
        // ignore: unawaited_futures
        Future.delayed(const Duration(seconds: 5), _checkAuthStatus);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('인증 상태 확인 실패: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );

        // 에러 무시하고 계속 확인
        // ignore: unawaited_futures
        Future.delayed(const Duration(seconds: 5), _checkAuthStatus);
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingAuth = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    var email = AuthService.getCurrentUserEmail();
    if (email == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('현재 로그인된 사용자가 없습니다.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Rate limit 체크 (마지막 요청으로부터 30초 이내면 경고)
    if (_lastResendTime != null) {
      var timeSinceLastResend = DateTime.now().difference(_lastResendTime!);
      if (timeSinceLastResend.inSeconds < 30) {
        if (mounted) {
          var remainingTime = 30 - timeSinceLastResend.inSeconds;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⏰ 너무 빈번한 요청입니다.\n$remainingTime초 후에 다시 시도해주세요.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isResending = true);
    _resendAttempts++;
    _lastResendTime = DateTime.now();

    try {
      var success = await AuthService.resendConfirmationEmail(
        email: email,
        context: context,
      );

      if (success) {
        // 성공 시 인증 상태를 즉시 확인
        Future.delayed(const Duration(seconds: 2), _checkAuthStatus);
      } else {
        // 실패 시 다시 시도
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이메일 재발송 실패'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이메일 재발송 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          '이메일 인증',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kToolbarHeight -
                  48, // AppBar height + padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이메일 아이콘
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    size: 40,
                    color: Color(0xFF6C5CE7),
                  ),
                ),

                const SizedBox(height: 24),

                // 제목
                const Text(
                  '이메일을 확인해주세요',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // 설명
                Text(
                  '${AuthService.getCurrentUserEmail() ?? ''}\n위 이메일로 인증 링크를 발송했습니다.\n\n이메일을 확인하고 인증 링크를 클릭해주세요.\n\n📧 인증 링크가 만료된 경우 아래 버튼으로\n새로운 인증 이메일을 받으실 수 있습니다.\n\n인증이 완료되면 자동으로 홈 화면으로 이동합니다.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Supabase 설정 가이드 (설정이 없거나 이메일 인증을 건너뛰고 싶은 경우)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '💡 이메일 인증을 건너뛰는 방법',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Supabase 대시보드에서 설정 변경:\n\n1. 🌐 supabase.com/dashboard 접속\n2. 프로젝트 선택\n3. Authentication → Settings\n4. "Enable email confirmations" OFF\n5. Save 버튼 클릭\n\n이렇게 하면 회원가입 시 이메일 인증 없이\n바로 로그인됩니다!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 재발송 시도 정보 표시
                if (_resendAttempts > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      '📮 이메일 재발송 시도: $_resendAttempts회\n💡 스팸 폴더도 확인해보세요!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_resendAttempts > 0) const SizedBox(height: 16),

                // 인증 상태 확인 중 표시
                if (_isCheckingAuth)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '인증 상태 확인 중...',
                          style: TextStyle(
                            color: Color(0xFF6C5CE7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // 이메일 재발송 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isResending ? null : _resendEmail,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6C5CE7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isResending
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF6C5CE7),
                              ),
                            )
                            : Text(
                              _resendAttempts == 0
                                  ? '📧 인증 이메일 다시 받기'
                                  : '📧 인증 이메일 다시 받기 (${_resendAttempts + 1}회)',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6C5CE7),
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 12),

                // 수동 새로고침 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isCheckingAuth ? null : _checkAuthStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '인증 상태 확인',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 뒤로가기
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/welcome');
                  },
                  child: const Text(
                    '로그인 화면으로 돌아가기',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
