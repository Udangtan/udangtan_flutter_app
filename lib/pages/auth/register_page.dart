import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  bool agreeAll = false;
  bool agree1 = false;
  bool agree2 = false;
  bool agree3 = false;

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로가기 버튼
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),

              const Center(
                child: Text(
                  '이메일로 가입',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이름
                    const Text(
                      '이름',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: '이름을 입력해주세요',
                        hintStyle: const TextStyle(color: Color(0xFFB2B2B2)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
                          ), // 기본 상태
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF9E4BDE),
                            width: 1,
                          ), // 포커스 상태
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => name = value,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? '이름을 입력해주세요'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // 이메일
                    const Text(
                      '이메일',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'ID@example.com',
                        hintStyle: const TextStyle(color: Color(0xFFB2B2B2)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
                          ), // 기본 상태
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF9E4BDE),
                            width: 1,
                          ), // 포커스 상태
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => email = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        } else if (!value.contains('@')) {
                          return '올바른 이메일 형식이 아닙니다';
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력해주세요.',
                        hintStyle: const TextStyle(color: Color(0xFFB2B2B2)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
                          ), // 기본 상태
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF9E4BDE),
                            width: 1,
                          ), // 포커스 상태
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) => password = value,
                      validator:
                          (value) =>
                              value == null || value.length < 6
                                  ? '6자 이상 입력해주세요'
                                  : null,
                    ),

                    const SizedBox(height: 24),
                    // 약관 체크박스
                    // 모두 동의
                    Row(
                      children: [
                        Checkbox(
                          value: agreeAll,
                          onChanged: (value) {
                            setState(() {
                              agreeAll = value ?? false;
                              agree1 = agreeAll;
                              agree2 = agreeAll;
                              agree3 = agreeAll;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '모두 동의 (선택포함)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF68717E),
                          ),
                        ),
                      ],
                    ),

                    // 이용약관
                    _agreementRow('이용약관', agree1, (v) {
                      setState(() => agree1 = v ?? false);
                    }, showView: true),

                    // 개인정보 취급방침
                    _agreementRow('개인정보 취급방침', agree2, (v) {
                      setState(() => agree2 = v ?? false);
                    }, showView: true),

                    // 마케팅 동의
                    _agreementRow('혜택 및 마케팅 정보 수신 동의(선택)', agree3, (v) {
                      setState(() => agree3 = v ?? false);
                    }, showView: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // 가입 버튼
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 110), // 110px 띄우기
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                showRequired1 = !agree1;
                showRequired2 = !agree2;
              });

              if (_formKey.currentState!.validate() && agree1 && agree2) {
                Navigator.pushNamed(context, '/register-success');
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9E4BDE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '가입하기',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  bool showRequired1 = false; // 이용약관 필수 표시 여부
  bool showRequired2 = false; // 개인정보 필수 표시 여부

  Widget _agreementRow(
    String title,
    bool value,
    Function(bool?) onChanged, {
    bool showView = true,
  }) {
    var showRequired =
        (title == '이용약관' && showRequired1) ||
        (title == '개인정보 취급방침' && showRequired2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (v) {
                onChanged(v);
                // 체크되면 필수 표시 끄기
                setState(() {
                  if (title == '이용약관') showRequired1 = false;
                  if (title == '개인정보 취급방침') showRequired2 = false;
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF68717E)),
            ),
            if (showRequired)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '필수',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        if (showView)
          const Text(
            '내용보기',
            style: TextStyle(fontSize: 14, color: Color(0xFF68717E)),
          ),
      ],
    );
  }
}
