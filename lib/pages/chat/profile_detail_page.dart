import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/tag_button.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade400, Colors.grey.shade300],
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.grey, size: 20),
              ),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            top: MediaQuery.of(context).size.height * 0.25,
            bottom: 40,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 50),
                      padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${pet.age}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '내 이름은 ${pet.name}😊',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '내 정보는',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TagButton(
                                text: '${pet.age}살',
                                color: AppColors.tagGrey,
                              ),
                              TagButton(
                                text: '산책 좋아',
                                color: AppColors.tagGrey,
                              ),
                              TagButton(
                                text: '야외 배변',
                                color: AppColors.tagGrey,
                              ),
                              TagButton(
                                text: '1일 2산책',
                                color: AppColors.tagGrey,
                              ),
                              TagButton(
                                text: '고리아스헤어',
                                color: AppColors.tagGrey,
                              ),
                              TagButton(text: '친구', color: AppColors.tagGrey),
                              TagButton(text: '고양이', color: AppColors.tagGrey),
                              TagButton(text: '수르놀아', color: AppColors.tagGrey),
                            ],
                          ),

                          const SizedBox(height: 24),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '이런 친구를 원해요',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TagButton(
                                text: '일일 급식',
                                color: AppColors.tagGrey,
                              ),
                              TagButton(
                                text: '주 1회 산책',
                                color: AppColors.tagGrey,
                              ),
                              TagButton(
                                text: '간식 나누',
                                color: AppColors.tagGrey,
                              ),
                              TagButton(
                                text: '사료 급식',
                                color: AppColors.tagGrey,
                              ),
                              TagButton(text: '아무거나', color: AppColors.tagGrey),
                              TagButton(text: '친구', color: AppColors.tagGrey),
                              TagButton(text: '고양이', color: AppColors.tagGrey),
                              TagButton(text: '수르놀아', color: AppColors.tagGrey),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              pet.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.pets,
                                    size: 50,
                                    color: Colors.white70,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
