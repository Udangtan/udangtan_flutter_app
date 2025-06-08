import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_styles.dart';

class PetPersonalitySelectionStep extends StatelessWidget {
  const PetPersonalitySelectionStep({
    super.key,
    required this.selectedPersonalities,
    required this.onPersonalityToggled,
  });

  final List<String> selectedPersonalities;
  final Function(String) onPersonalityToggled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyles.paddingAll20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '성격을 선택해주세요',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '해당하는 성격을 모두 선택해주세요 (다중 선택 가능)',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          Container(
            padding: AppStyles.paddingAll20,
            decoration: AppStyles.cardDecoration,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  Pet.personalityOptions
                      .map(
                        (personality) => _PersonalityChip(
                          personality: personality,
                          isSelected: selectedPersonalities.contains(
                            personality,
                          ),
                          onTap: () => onPersonalityToggled(personality),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalityChip extends StatelessWidget {
  const _PersonalityChip({
    required this.personality,
    required this.isSelected,
    required this.onTap,
  });

  final String personality;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppStyles.paddingSymmetric16_8,
        decoration: AppStyles.tagDecoration(isSelected: isSelected),
        child: Text(
          personality,
          style: TextStyle(
            color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
