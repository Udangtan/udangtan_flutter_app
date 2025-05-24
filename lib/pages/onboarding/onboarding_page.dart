import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _StepData {
  _StepData({required this.question, required this.options});

  final String question;
  final List<String> options;
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentStep = 0;
  String? selectedValue;
  final nicknameController = TextEditingController();
  final bioController = TextEditingController();
  final List<String> selectedTags = [];

  final List<_StepData> steps = [
    _StepData(
      question: '어떤 친구와 함께하고 계신가요?',
      options: ['🐶 강아지', '🐱 고양이', '🐰 토끼', '🐦 새', '🦎 기타(직접 입력하기)'],
    ),
    _StepData(question: '성별을 선택해주세요!', options: ['♂ 수컷', '♀ 암컷']),
    _StepData(
      question: '나이는 몇 살인가요?',
      options: ['0~1 세', '2~4 세', '5~7 세', '8 세 이상'],
    ),
  ];

  void _nextStep() {
    if (currentStep < steps.length) {
      setState(() {
        currentStep++;
        selectedValue = null;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding-success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정보 등록'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child:
            currentStep == 0
                ? _buildUserInputStep()
                : _buildQuestionStep(steps[currentStep - 1]),
      ),
    );
  }

  Widget _buildUserInputStep() {
    var tagList = [
      '활발함',
      '조용함',
      '사교적',
      '낯가림',
      '애교많음',
      '까칠함',
      '장난꾸러기',
      '순함',
      '지능적',
      '귀여움',
      '털털함',
      '예민함',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EJ님\n대표 이미지를 등록해 주세요 :)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 24),
        const Text('닉네임'),
        TextField(controller: nicknameController),
        const SizedBox(height: 16),
        const Text('자기소개글'),
        TextField(
          controller: bioController,
          decoration: const InputDecoration(hintText: '간단하게 자기를 소개해주세요!'),
        ),
        const SizedBox(height: 24),
        const Text('성격 선택하기'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              tagList.map((tag) {
                var isSelected = selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected
                          ? selectedTags.remove(tag)
                          : selectedTags.add(tag);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple),
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected ? Colors.purple : Colors.white,
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.purple,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('다음'),
        ),
      ],
    );
  }

  Widget _buildQuestionStep(_StepData step) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 140,
          child: Image.asset(
            'assets/images/onboarding_step_$currentStep.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          step.question,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...step.options.map(
          (option) => RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedValue,
            onChanged: (value) => setState(() => selectedValue = value),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: selectedValue == null ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('다음'),
        ),
      ],
    );
  }
}
