import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/tag_button.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    const double imageSize = 100;
    const double bottomSheetMaxHeightRatio = 0.7;
    const double bottomSheetMinHeightRatio = 0.5;

    return Scaffold(
      body: Stack(
        children: [
          Container(height: screenHeight, color: AppColors.primary),
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: bottomSheetMaxHeightRatio,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight * bottomSheetMinHeightRatio,
                  maxHeight: screenHeight * bottomSheetMaxHeightRatio,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: imageSize / 2 + 20,
                      left: 20,
                      right: 20,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
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
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TagButton(
                                text: '${pet.age}살',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '산책 좋아',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '야외 배변',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '1일 2산책',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '코리안숏헤어',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '친구',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '고양이',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '츄르좋아',
                                color: AppColors.tagBackground,
                              ),
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
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TagButton(
                                text: '입질 금지',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '주 1회 산책',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '간식 나눔',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '사심 금지',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '여자만',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '친구',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '고양이',
                                color: AppColors.tagBackground,
                              ),
                              TagButton(
                                text: '츄르 좋아',
                                color: AppColors.tagBackground,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top:
                screenHeight * (1 - bottomSheetMaxHeightRatio) -
                (imageSize / 2),
            left: 0,
            right: 0,
            child: Center(
              child: ClipOval(
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.white,
                  child: Image.asset(
                    pet.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.pets,
                          size: 50,
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
