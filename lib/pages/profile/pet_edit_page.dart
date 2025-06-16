import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/services/image_service.dart';
import 'package:udangtan_flutter_app/services/pet_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';

class PetEditPage extends StatefulWidget {
  const PetEditPage({super.key, required this.pet});

  final Pet pet;

  @override
  State<PetEditPage> createState() => _PetEditPageState();
}

class _PetEditPageState extends State<PetEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isUploadingImage = false;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Form data
  String? _selectedBreed;
  String? _selectedGender;
  String? _selectedSize;
  String? _selectedActivityLevel;
  String? _selectedIsNeutered;
  String? _selectedVaccinationStatus;
  final List<String> _selectedPersonalities = [];

  // Image data
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeWithPetData();
  }

  void _initializeWithPetData() {
    // 기존 펫 정보로 폼 초기화
    _nameController.text = widget.pet.name;
    _ageController.text = widget.pet.age.toString();
    _weightController.text = widget.pet.weight?.toString() ?? '';
    _descriptionController.text = widget.pet.description ?? '';

    // 기존 이미지 URL 설정
    if (widget.pet.profileImages.isNotEmpty) {
      _currentImageUrl = widget.pet.profileImages.first;
    }

    // 품종은 선택된 종에 따라 유효한지 확인
    var validBreeds = PetService.breedOptions[widget.pet.species] ?? [];
    _selectedBreed =
        validBreeds.contains(widget.pet.breed) ? widget.pet.breed : null;

    _selectedGender = widget.pet.gender;

    // 드롭다운 값들은 유효한 값인지 확인 후 설정
    var validSizes = ['소형', '중형', '대형'];
    _selectedSize =
        validSizes.contains(widget.pet.size) ? widget.pet.size : null;

    var validActivityLevels = ['낮음', '보통', '높음'];
    _selectedActivityLevel =
        validActivityLevels.contains(widget.pet.activityLevel)
            ? widget.pet.activityLevel
            : null;

    var validNeuteringStatus = ['완료', '안함', '모름'];
    _selectedIsNeutered =
        validNeuteringStatus.contains(widget.pet.isNeutered)
            ? widget.pet.isNeutered
            : null;

    var validVaccinationStatus = ['완료', '미완료', '진행중', '모름'];
    _selectedVaccinationStatus =
        validVaccinationStatus.contains(widget.pet.vaccinationStatus)
            ? widget.pet.vaccinationStatus
            : null;

    _selectedPersonalities.addAll(widget.pet.personality);
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
      _currentImageUrl = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validatePetData() {
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

  Future<void> _updatePet() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validatePetData()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _currentImageUrl;

      // 새 이미지가 선택되었다면 업로드
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);
        imageUrl = await ImageService.uploadPetImage(
          _selectedImage!,
          widget.pet.id!,
        );
        setState(() => _isUploadingImage = false);
      }

      List<String> profileImages = [];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        profileImages.add(imageUrl);
      }

      Pet updatedPet = Pet(
        id: widget.pet.id,
        ownerId: widget.pet.ownerId,
        name: _nameController.text.trim(),
        species: widget.pet.species, // 종류는 변경 불가
        breed: _selectedBreed!,
        age: int.parse(_ageController.text),
        gender: _selectedGender!,
        profileImages: profileImages,
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
        createdAt: widget.pet.createdAt,
        updatedAt: DateTime.now(),
      );

      await PetService.updatePet(updatedPet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('반려동물 정보가 수정되었습니다! 🎉'),
            backgroundColor: Color(0xFF6C5CE7),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var breeds = PetService.breedOptions[widget.pet.species] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(title: '${widget.pet.name} 정보 수정'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지 섹션
              _buildSectionTitle('프로필 사진'),
              _buildImageSection(),
              const SizedBox(height: 20),

              // 동물 종류 (수정 불가)
              _buildSectionTitle('동물 종류'),
              _buildDisabledField(widget.pet.species),
              const SizedBox(height: 20),

              // 품종
              _buildSectionTitle('품종 *'),
              _buildDropdownField(
                value: _selectedBreed,
                hint: '품종을 선택하세요',
                items: breeds,
                onChanged: (value) => setState(() => _selectedBreed = value),
              ),
              const SizedBox(height: 20),

              // 성별
              _buildSectionTitle('성별 *'),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderCard('수컷', _selectedGender == '수컷'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderCard('암컷', _selectedGender == '암컷'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 이름
              _buildSectionTitle('이름 *'),
              _buildTextField(
                controller: _nameController,
                hint: '반려동물의 이름을 입력하세요',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 나이
              _buildSectionTitle('나이 *'),
              _buildTextField(
                controller: _ageController,
                hint: '나이를 입력하세요',
                keyboardType: TextInputType.number,
                suffixText: '살',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '나이를 입력해주세요';
                  }
                  var age = int.tryParse(value.trim());
                  if (age == null || age <= 0 || age > 30) {
                    return '유효한 나이를 입력해주세요 (1-30세)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 성격
              _buildSectionTitle('성격 *'),
              _buildPersonalitySection(),
              const SizedBox(height: 20),

              // 몸무게
              _buildSectionTitle('몸무게'),
              _buildTextField(
                controller: _weightController,
                hint: '몸무게를 입력하세요',
                keyboardType: TextInputType.number,
                suffixText: 'kg',
              ),
              const SizedBox(height: 20),

              // 크기
              _buildSectionTitle('크기'),
              _buildDropdownField(
                value: _selectedSize,
                hint: '크기를 선택하세요',
                items: ['소형', '중형', '대형'],
                onChanged: (value) => setState(() => _selectedSize = value),
              ),
              const SizedBox(height: 20),

              // 활동량
              _buildSectionTitle('활동량'),
              _buildDropdownField(
                value: _selectedActivityLevel,
                hint: '활동량을 선택하세요',
                items: ['낮음', '보통', '높음'],
                onChanged:
                    (value) => setState(() => _selectedActivityLevel = value),
              ),
              const SizedBox(height: 20),

              // 중성화 여부
              _buildSectionTitle('중성화 여부'),
              _buildDropdownField(
                value: _selectedIsNeutered,
                hint: '중성화 여부를 선택하세요',
                items: ['완료', '안함', '모름'],
                onChanged:
                    (value) => setState(() => _selectedIsNeutered = value),
              ),
              const SizedBox(height: 20),

              // 예방접종 상태
              _buildSectionTitle('예방접종 상태'),
              _buildDropdownField(
                value: _selectedVaccinationStatus,
                hint: '예방접종 상태를 선택하세요',
                items: ['완료', '미완료', '진행중', '모름'],
                onChanged:
                    (value) =>
                        setState(() => _selectedVaccinationStatus = value),
              ),
              const SizedBox(height: 20),

              // 설명
              _buildSectionTitle('설명'),
              _buildTextField(
                controller: _descriptionController,
                hint: '반려동물에 대한 추가 설명을 입력하세요',
                maxLines: 4,
              ),
              const SizedBox(height: 40),

              // 수정 완료 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_isLoading || _isUploadingImage) ? null : _updatePet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      (_isLoading || _isUploadingImage)
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _isUploadingImage ? '이미지 업로드 중...' : '수정 중...',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                          : const Text(
                            '수정 완료',
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
          if (_selectedImage != null || _currentImageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  _selectedImage != null
                      ? Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Image.network(
                        _currentImageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDisabledField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        value,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? suffixText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffixText,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
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
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalitySection() {
    List<String> personalityOptions = [
      '활발한',
      '온순한',
      '친근한',
      '독립적인',
      '장난기많은',
      '조용한',
      '사교적인',
      '보호본능',
      '충성스러운',
      '호기심많은',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          personalityOptions.map((personality) {
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
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  personality,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
