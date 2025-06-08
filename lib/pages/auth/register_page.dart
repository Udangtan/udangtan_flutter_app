import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:udangtan_flutter_app/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _agreeAll = false;
  bool _agree1 = false; // 이용약관 (필수)
  bool _agree2 = false; // 개인정보 처리방침 (필수)
  bool _agree3 = false; // 마케팅 정보 수신 (선택)
  bool _obscurePassword = true;
  bool _showRequired1 = false;
  bool _showRequired2 = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _showRequired1 = !_agree1;
      _showRequired2 = !_agree2;
    });

    if (!_formKey.currentState!.validate() || !_agree1 || !_agree2) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      var response = await AuthService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        context: context,
      );

      if (response != null && mounted) {
        // 이메일 확인이 비활성화된 경우 (즉시 확인됨)
        if (response.user!.emailConfirmedAt != null) {
          // 바로 홈으로 이동
          await Navigator.pushReplacementNamed(context, '/home');
        } else {
          // 이메일 확인이 필요한 경우 인증 페이지로 이동
          await Navigator.pushReplacementNamed(context, '/register-success');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateAgreeAll() {
    setState(() {
      _agreeAll = _agree1 && _agree2 && _agree3;
    });
  }

  void _handleAgreeAll(bool? value) {
    setState(() {
      _agreeAll = value ?? false;
      _agree1 = _agreeAll;
      _agree2 = _agreeAll;
      _agree3 = _agreeAll;
      _showRequired1 = false;
      _showRequired2 = false;
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '이메일로 가입',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 이름
                const Text(
                  '이름',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '이름을 입력해주세요',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 이메일
                const Text(
                  '이메일',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'example@gmail.com',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    // 더 정확한 이메일 형식 검증
                    if (!RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(value.trim())) {
                      return '올바른 이메일 형식을 입력해주세요';
                    }
                    // test 도메인 사용 방지 안내
                    if (value.trim().toLowerCase().endsWith('@test.com')) {
                      return '실제 사용 가능한 이메일 주소를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 비밀번호
                const Text(
                  '비밀번호',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '6자 이상 입력해주세요',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '6자 이상 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // 약관 동의
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // 전체 동의
                      GestureDetector(
                        onTap: () => _handleAgreeAll(!_agreeAll),
                        child: Row(
                          children: [
                            Icon(
                              _agreeAll
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color:
                                  _agreeAll
                                      ? const Color(0xFF6C5CE7)
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '전체 동의',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 24),

                      // 이용약관 동의 (필수)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _agree1 = !_agree1;
                            _showRequired1 = false;
                            _updateAgreeAll();
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _agree1
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color:
                                  _showRequired1
                                      ? Colors.red
                                      : _agree1
                                      ? const Color(0xFF6C5CE7)
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '이용약관 동의 (필수)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      _showRequired1
                                          ? Colors.red
                                          : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 개인정보 처리방침 동의 (필수)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _agree2 = !_agree2;
                            _showRequired2 = false;
                            _updateAgreeAll();
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _agree2
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color:
                                  _showRequired2
                                      ? Colors.red
                                      : _agree2
                                      ? const Color(0xFF6C5CE7)
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '개인정보 처리방침 동의 (필수)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      _showRequired2
                                          ? Colors.red
                                          : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 마케팅 정보 수신 동의 (선택)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _agree3 = !_agree3;
                            _updateAgreeAll();
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _agree3
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color:
                                  _agree3
                                      ? const Color(0xFF6C5CE7)
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                '마케팅 정보 수신 동의 (선택)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                            : const Text(
                              '회원가입',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
