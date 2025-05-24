import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/features/pet/widgets/pet_traits_modal.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_text_styles.dart';
import 'package:udangtan_flutter_app/shared/widgets/tag_button.dart';

class PetCard extends StatelessWidget {
  const PetCard({super.key, required this.pet, this.position = 0});

  final Pet pet;
  final double position;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(position, 0),
      child: Transform.rotate(
        angle: position / 1000,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            // color: AppColors.white,
            // border: Border.all(color: AppColors.borderLight, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildImageAndFeaturesSection(context)),
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageAndFeaturesSection(BuildContext context) {
    return Padding(
      // padding: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
            color: AppColors.cardBackground,
          ),
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  pet.imageUrl,
                  // fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.pets, size: 150, color: Colors.white70),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    _buildPetInfo(),
                    const SizedBox(height: 16),
                    _buildFeaturesSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPetInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${pet.name} ${pet.age}', style: AppTextStyles.petName),
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.textWhite, size: 14),
            Text(
              '${pet.location} · ${pet.distance}',
              style: AppTextStyles.petInfo,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.pets, color: AppColors.textWhite, size: 14),
            const SizedBox(width: 4),
            Text(pet.type, style: AppTextStyles.petInfo),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pet.description, style: AppTextStyles.description),
          const SizedBox(height: 8),
          Row(
            children:
                pet.tags.asMap().entries.map((entry) {
                  var index = entry.key;
                  var tag = entry.value;
                  var isLast = index == pet.tags.length - 1;
                  var isMoreTag = tag.startsWith('+');

                  Color tagColor = AppColors.tagBackground;
                  if (index == 1) tagColor = AppColors.primaryWithOpacity10;
                  if (isLast) tagColor = AppColors.transparent;

                  return Row(
                    children: [
                      GestureDetector(
                        onTap:
                            isMoreTag ? () => _showTraitsModal(context) : null,
                        child: TagButton(
                          text: tag,
                          color: tagColor,
                          isClickable: isMoreTag,
                        ),
                      ),
                      if (!isLast) const SizedBox(width: 8),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  void _showTraitsModal(BuildContext context) {
    PetTraitsModal.show(context, pet);
  }

  Widget _buildActionSection() {
    return Padding(
      // padding: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE9D7F7),
                  foregroundColor: const Color(0xFF9E4BDE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('괜찮아요', style: AppTextStyles.buttonText),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E4BDE),
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('간식주기', style: AppTextStyles.buttonText),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
