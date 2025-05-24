import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_styles.dart';

class PetBasicInfoStep extends StatelessWidget {
  const PetBasicInfoStep({
    super.key,
    required this.name,
    required this.selectedAgeRange,
    required this.onNameChanged,
    required this.onAgeRangeSelected,
  });

  final String name;
  final String? selectedAgeRange;
  final Function(String) onNameChanged;
  final Function(String) onAgeRangeSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyles.paddingAll20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기본 정보를 입력해주세요',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이름과 나이를 알려주세요',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          Container(
            padding: AppStyles.paddingAll20,
            decoration: AppStyles.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이름',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: onNameChanged,
                  decoration: AppStyles.inputDecoration(
                    hintText: '반려동물의 이름을 입력하세요',
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '나이',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...Pet.ageRangeOptions.map(
                  (age) => _AgeRangeRadioTile(
                    age: age,
                    selectedAge: selectedAgeRange,
                    onSelected: onAgeRangeSelected,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeRangeRadioTile extends StatelessWidget {
  const _AgeRangeRadioTile({
    required this.age,
    required this.selectedAge,
    required this.onSelected,
  });

  final String age;
  final String? selectedAge;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyles.marginVertical8,
      child: GestureDetector(
        onTap: () => onSelected(age),
        child: Row(
          children: [
            Radio<String>(
              value: age,
              groupValue: selectedAge,
              onChanged: (value) {
                if (value != null) onSelected(value);
              },
              activeColor: AppColors.primary,
            ),
            Text(
              age,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
