import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/features/pet/widgets/pet_basic_info_step.dart';
import 'package:udangtan_flutter_app/features/pet/widgets/pet_gender_selection_step.dart';
import 'package:udangtan_flutter_app/features/pet/widgets/pet_personality_selection_step.dart';
import 'package:udangtan_flutter_app/features/pet/widgets/pet_type_selection_step.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/pages/profile/pet_registration_complete_page.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_styles.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';

class PetRegistrationPage extends StatefulWidget {
  const PetRegistrationPage({super.key});

  @override
  State<PetRegistrationPage> createState() => _PetRegistrationPageState();
}

class _PetRegistrationPageState extends State<PetRegistrationPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Registration data
  String? _selectedType;
  String? _selectedGender;
  String _name = '';
  String? _selectedAgeRange;
  final List<String> _selectedPersonalities = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0:
        return _selectedType != null;
      case 1:
        return _selectedGender != null;
      case 2:
        return _name.isNotEmpty && _selectedAgeRange != null;
      case 3:
        return _selectedPersonalities.isNotEmpty;
      default:
        return false;
    }
  }

  void _completeRegistration() async {
    if (!_canProceedToNext()) return;

    var newPet = Pet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name,
      age: _getAgeFromRange(_selectedAgeRange!),
      location: '서울 강동구',
      distance: '0m',
      type: _selectedType!,
      imageUrl: '',
      tags: _selectedPersonalities.take(2).map((p) => '🐾 $p').toList(),
      allTags: _selectedPersonalities.map((p) => '🐾 $p').toList(),
      description: '$_name는 ${_selectedPersonalities.join(', ')} 성격이에요!',
      gender: _selectedGender,
      breed: '품종 미등록',
      personalities: _selectedPersonalities,
      ageRange: _selectedAgeRange,
      isMyPet: true,
    );

    var result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PetRegistrationCompletePage(pet: newPet),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, newPet);
    }
  }

  int _getAgeFromRange(String ageRange) {
    switch (ageRange) {
      case '1살 미만':
        return 0;
      case '1-3살':
        return 2;
      case '4-7살':
        return 5;
      case '8살 이상':
        return 10;
      default:
        return 3;
    }
  }

  void _onPersonalityToggled(String personality) {
    setState(() {
      if (_selectedPersonalities.contains(personality)) {
        _selectedPersonalities.remove(personality);
      } else {
        _selectedPersonalities.add(personality);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: '반려동물 등록',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              _currentStep > 0 ? _previousStep : () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                PetTypeSelectionStep(
                  selectedType: _selectedType,
                  onTypeSelected:
                      (type) => setState(() => _selectedType = type),
                ),
                PetGenderSelectionStep(
                  selectedGender: _selectedGender,
                  onGenderSelected:
                      (gender) => setState(() => _selectedGender = gender),
                ),
                PetBasicInfoStep(
                  name: _name,
                  selectedAgeRange: _selectedAgeRange,
                  onNameChanged: (name) => setState(() => _name = name),
                  onAgeRangeSelected:
                      (ageRange) =>
                          setState(() => _selectedAgeRange = ageRange),
                ),
                PetPersonalitySelectionStep(
                  selectedPersonalities: _selectedPersonalities,
                  onPersonalityToggled: _onPersonalityToggled,
                ),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: AppStyles.paddingAll20,
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color:
                    index <= _currentStep
                        ? AppColors.primary
                        : AppColors.borderLight,
                borderRadius: AppStyles.borderRadius8.copyWith(
                  topLeft: const Radius.circular(2),
                  topRight: const Radius.circular(2),
                  bottomLeft: const Radius.circular(2),
                  bottomRight: const Radius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButton() {
    var isLastStep = _currentStep == 3;
    var canProceed = _canProceedToNext();

    return Container(
      padding: AppStyles.paddingAll20,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              canProceed
                  ? (isLastStep ? _completeRegistration : _nextStep)
                  : null,
          style: AppStyles.primaryButtonStyle,
          child: Text(
            isLastStep ? '등록하기' : '다음',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
