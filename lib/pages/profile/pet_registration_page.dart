import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/pages/profile/pet_registration_complete_page.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/pet_service.dart';
import 'package:udangtan_flutter_app/services/image_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';

class PetRegistrationPage extends StatefulWidget {
  const PetRegistrationPage({super.key});

  @override
  State<PetRegistrationPage> createState() => _PetRegistrationPageState();
}

class _PetRegistrationPageState extends State<PetRegistrationPage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Form data
  String? _selectedSpecies;
  String? _selectedBreed;
  String? _selectedGender;
  String? _selectedSize;
  String? _selectedActivityLevel;
  String? _selectedIsNeutered;
  String? _selectedVaccinationStatus;
  final List<String> _selectedPersonalities = [];

  // Image data
  File? _selectedImage;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
    });
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0:
        return true; // 이미지는 선택사항
      case 1:
        return _selectedSpecies != null;
      case 2:
        return _selectedBreed != null && _selectedGender != null;
      case 3:
        return _nameController.text.isNotEmpty &&
            _ageController.text.isNotEmpty;
      case 4:
        return _selectedPersonalities.isNotEmpty;
      case 5:
        return true; // 선택사항들
      default:
        return false;
    }
  }

  bool _validatePetData() {
    if (_selectedSpecies == null || _selectedSpecies!.isEmpty) {
      _showValidationError('동물 종류를 선택해주세요.');
      return false;
    }

    if (_selectedBreed == null || _selectedBreed!.isEmpty) {
      _showValidationError('품종을 선택해주세요.');
      return false;
    }

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      _showValidationError('성별을 선택해주세요.');
      return false;
    }

    if (_nameController.text.trim().isEmpty) {
      _showValidationError('이름을 입력해주세요.');
      return false;
    }

    if (_ageController.text.trim().isEmpty) {
      _showValidationError('나이를 입력해주세요.');
      return false;
    }

    var age = int.tryParse(_ageController.text.trim());
    if (age == null || age <= 0 || age > 30) {
      _showValidationError('유효한 나이를 입력해주세요. (1-30세)');
      return false;
    }

    if (_selectedPersonalities.isEmpty) {
      _showValidationError('성격을 최소 1개 이상 선택해주세요.');
      return false;
    }

    if (_weightController.text.isNotEmpty) {
      var weight = double.tryParse(_weightController.text.trim());
      if (weight == null || weight <= 0 || weight > 200) {
        _showValidationError('유효한 몸무게를 입력해주세요. (0-200kg)');
        return false;
      }
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitPet() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_validatePetData()) return;

    setState(() => _isLoading = true);

    try {
      var userId = AuthService.getCurrentUserId();

      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      Pet pet = Pet(
        ownerId: '',
        name: _nameController.text.trim(),
        species: _selectedSpecies!,
        breed: _selectedBreed!,
        age: int.parse(_ageController.text),
        gender: _selectedGender!,
        profileImages: [],
        personality: _selectedPersonalities,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        isNeutered: _selectedIsNeutered,
        vaccinationStatus: _selectedVaccinationStatus,
        weight:
            _weightController.text.isEmpty
                ? null
                : double.tryParse(_weightController.text),
        size: _selectedSize,
        activityLevel: _selectedActivityLevel,
      );

      Pet createdPet = await PetService.createPet(pet);

      // 이미지가 선택되었다면 업로드
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);
        try {
          String imageUrl = await ImageService.uploadPetImage(
            _selectedImage!,
            createdPet.id!,
          );

          // 이미지 URL로 펫 정보 업데이트
          Pet updatedPet = createdPet.copyWith(profileImages: [imageUrl]);

          createdPet = await PetService.updatePet(updatedPet);
        } catch (imageError) {
          // 이미지 업로드 실패해도 펫 등록은 계속 진행
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('이미지 업로드 실패: $imageError'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } finally {
          setState(() => _isUploadingImage = false);
        }
      }

      if (mounted) {
        var result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PetRegistrationCompletePage(pet: createdPet),
          ),
        );

        // 등록 완료 후 프로필 페이지로 돌아가면서 새로고침 신호 전달
        if (mounted && result == true) {
          Navigator.pop(context, true); // 프로필 페이지에 새로고침 신호 전달
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(
        title: '반려동물 등록',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              _currentStep > 0 ? _previousStep : () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildImageStep(),
                  _buildSpeciesStep(),
                  _buildBreedGenderStep(),
                  _buildBasicInfoStep(),
                  _buildPersonalityStep(),
                  _buildAdditionalInfoStep(),
                ],
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(6, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color:
                    index <= _currentStep
                        ? AppColors.primary
                        : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildImageStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '프로필 사진을 등록해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '반려동물의 사진을 선택해주세요 (선택사항)',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          _buildImageSection(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          if (_selectedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.edit),
                    label: const Text('이미지 변경'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _removeImage,
                    icon: const Icon(Icons.delete),
                    label: const Text('이미지 삭제'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '프로필 사진 없음',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '나중에도 추가할 수 있어요',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('이미지 추가'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeciesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '어떤 반려동물인가요?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '반려동물의 종류를 선택해주세요',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _buildSpeciesCard(
                  '강아지',
                  Icons.pets,
                  _selectedSpecies == '강아지',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSpeciesCard(
                  '고양이',
                  Icons.pets,
                  _selectedSpecies == '고양이',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesCard(String species, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSpecies = species),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 12),
            Text(
              species,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedGenderStep() {
    List<String> breeds =
        _selectedSpecies != null
            ? PetService.breedOptions[_selectedSpecies!] ?? []
            : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '품종과 성별을 알려주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '반려동물의 품종과 성별을 선택해주세요',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // 품종 선택
          const Text(
            '품종',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBreed,
                hint: const Text('품종을 선택하세요'),
                isExpanded: true,
                items:
                    breeds.map((breed) {
                      return DropdownMenuItem(value: breed, child: Text(breed));
                    }).toList(),
                onChanged: (value) => setState(() => _selectedBreed = value),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 성별 선택
          const Text(
            '성별',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildGenderCard('수컷', _selectedGender == '수컷')),
              const SizedBox(width: 16),
              Expanded(child: _buildGenderCard('암컷', _selectedGender == '암컷')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(String gender, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          gender,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[800],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기본 정보를 입력해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '반려동물의 이름과 나이를 알려주세요',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // 이름 입력
          const Text(
            '이름 *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            onChanged: (value) {
              // 디바운스 방식으로 setState 호출 최적화
              if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                if (mounted) setState(() {});
              });
            },
            decoration: InputDecoration(
              hintText: '반려동물의 이름을 입력하세요',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이름을 입력해주세요';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // 나이 입력
          const Text(
            '나이 *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // 디바운스 방식으로 setState 호출 최적화
              if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                if (mounted) setState(() {});
              });
            },
            decoration: InputDecoration(
              hintText: '나이를 입력하세요 (숫자만)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '나이를 입력해주세요';
              }
              if (int.tryParse(value) == null) {
                return '유효한 나이를 입력해주세요';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '성격을 선택해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '반려동물의 성격을 여러 개 선택할 수 있어요',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: PetService.personalityOptions.length,
              itemBuilder: (context, index) {
                String personality = PetService.personalityOptions[index];
                bool isSelected = _selectedPersonalities.contains(personality);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedPersonalities.remove(personality);
                      } else {
                        _selectedPersonalities.add(personality);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        personality,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '추가 정보 (선택사항)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '더 자세한 정보를 입력하면 더 좋은 매칭이 가능해요',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // 몸무게
          const Text(
            '몸무게 (kg)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '몸무게를 입력하세요',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 크기
          const Text(
            '크기',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedSize,
            items: PetService.sizeOptions,
            hint: '크기를 선택하세요',
            onChanged: (value) => setState(() => _selectedSize = value),
          ),

          const SizedBox(height: 20),

          // 활동량
          const Text(
            '활동량',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedActivityLevel,
            items: PetService.activityLevelOptions,
            hint: '활동량을 선택하세요',
            onChanged:
                (value) => setState(() => _selectedActivityLevel = value),
          ),

          const SizedBox(height: 20),

          // 중성화 상태
          const Text(
            '중성화 상태',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedIsNeutered,
            items: PetService.neuteringStatusOptions,
            hint: '중성화 상태를 선택하세요',
            onChanged: (value) => setState(() => _selectedIsNeutered = value),
          ),

          const SizedBox(height: 20),

          // 예방접종 상태
          const Text(
            '예방접종 상태',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedVaccinationStatus,
            items: PetService.vaccinationStatusOptions,
            hint: '예방접종 상태를 선택하세요',
            onChanged:
                (value) => setState(() => _selectedVaccinationStatus = value),
          ),

          const SizedBox(height: 20),

          // 설명
          const Text(
            '추가 설명',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '반려동물에 대한 추가 설명을 입력하세요',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items:
              items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed:
              (_isLoading || _isUploadingImage)
                  ? null
                  : (_currentStep == 5
                      ? _submitPet
                      : _canProceedToNext()
                      ? _nextStep
                      : null),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child:
              (_isLoading || _isUploadingImage)
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isUploadingImage ? '이미지 업로드 중...' : '등록 중...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    _currentStep == 5 ? '등록 완료' : '다음',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
        ),
      ),
    );
  }
}
