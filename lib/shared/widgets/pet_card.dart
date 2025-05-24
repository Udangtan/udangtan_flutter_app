import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_text_styles.dart';
import 'package:udangtan_flutter_app/shared/widgets/pet_traits_modal.dart';
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
            color: AppColors.white,
            border: Border.all(color: AppColors.cardBorder, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildImageSection()),
              _buildFeaturesSection(context),
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
        color: AppColors.cardBackground,
      ),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: 30,
            child: Text('Recording Puppy Life', style: AppTextStyles.cardTitle),
          ),
          Center(
            child: Image.asset(
              pet.imageUrl,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.pets, size: 150, color: Colors.white70),
            ),
          ),
          Positioned(bottom: 10, left: 10, child: _buildPetInfo()),
        ],
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
            const Icon(Icons.location_on, color: AppColors.cardText, size: 14),
            Text(
              '${pet.location} · ${pet.distance}',
              style: AppTextStyles.petInfo,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.pets, color: AppColors.cardText, size: 14),
            const SizedBox(width: 4),
            Text(pet.type, style: AppTextStyles.petInfo),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
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

                  Color tagColor = AppColors.tagGrey;
                  if (index == 1) tagColor = AppColors.tagBlue;
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
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
              ),
              child: const Text('괜찮아요', style: AppTextStyles.buttonText),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('간식주기', style: AppTextStyles.buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
