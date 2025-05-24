import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_styles.dart';

class PetGenderSelectionStep extends StatelessWidget {
  const PetGenderSelectionStep({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  final String? selectedGender;
  final Function(String) onGenderSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyles.paddingAll20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '성별을 선택해주세요',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '반려동물의 성별을 알려주세요',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  gender: '수컷',
                  icon: Icons.male,
                  color: AppColors.maleColor,
                  isSelected: selectedGender == '수컷',
                  onTap: () => onGenderSelected('수컷'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GenderCard(
                  gender: '암컷',
                  icon: Icons.female,
                  color: AppColors.femaleColor,
                  isSelected: selectedGender == '암컷',
                  onTap: () => onGenderSelected('암컷'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.gender,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String gender;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppStyles.selectionCardDecoration(isSelected: isSelected),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: AppStyles.circleAvatarDecoration(
                isSelected ? AppColors.primary : color,
              ),
              child: Icon(icon, color: AppColors.textWhite, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              gender,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
