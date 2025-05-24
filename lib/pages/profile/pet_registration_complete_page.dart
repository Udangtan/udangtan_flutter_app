import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_styles.dart';

class PetRegistrationCompletePage extends StatelessWidget {
  const PetRegistrationCompletePage({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: AppStyles.paddingAll20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: AppStyles.circleAvatarDecoration(AppColors.primary),
                child: const Icon(
                  Icons.check,
                  color: AppColors.textWhite,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '정보 등록완료!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${pet.name}의 정보가 성공적으로 등록되었어요',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Container(
                padding: AppStyles.paddingAll20,
                decoration: AppStyles.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: AppStyles.circleAvatarDecoration(
                            pet.type == '강아지'
                                ? AppColors.dogColor
                                : AppColors.catColor,
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: AppColors.textWhite,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${pet.type} • ${pet.gender} • ${pet.ageRange}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (pet.personalities.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '성격',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            pet.personalities.map((personality) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryWithOpacity10,
                                  borderRadius: AppStyles.borderRadius12,
                                  border: Border.all(
                                    color: AppColors.primaryWithOpacity30,
                                  ),
                                ),
                                child: Text(
                                  personality,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: AppStyles.primaryButtonStyle,
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
