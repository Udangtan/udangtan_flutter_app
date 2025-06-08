import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_styles.dart';

class PetTypeSelectionStep extends StatelessWidget {
  const PetTypeSelectionStep({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final String? selectedType;
  final Function(String) onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyles.paddingAll20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '어떤 반려동물인가요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '반려동물의 종류를 선택해주세요',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _PetTypeCard(
                  type: '강아지',
                  icon: Icons.pets,
                  color: AppColors.dogColor,
                  isSelected: selectedType == '강아지',
                  onTap: () => onTypeSelected('강아지'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PetTypeCard(
                  type: '고양이',
                  icon: Icons.pets,
                  color: AppColors.catColor,
                  isSelected: selectedType == '고양이',
                  onTap: () => onTypeSelected('고양이'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PetTypeCard extends StatelessWidget {
  const _PetTypeCard({
    required this.type,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String type;
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
              type,
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
