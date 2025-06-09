import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/features/home/widgets/pet_card_stack.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';
import 'package:udangtan_flutter_app/shared/widgets/location_display_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.currentNavIndex,
    required this.onNavTap,
    required this.onPetLiked,
    required this.onSwipeStateChanged,
  });

  final int currentNavIndex;
  final Function(int) onNavTap;
  final Function(Pet) onPetLiked;
  final Function(bool isActive, double opacity) onSwipeStateChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(
        title: '우당탕',
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Expanded(
                  child: LocationDisplayWidget(
                    padding: EdgeInsets.zero,
                    showIcon: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: PetCardStack(
                onSwipe: (pet, result) {
                  if (result == SwipeResult.approve) {
                    widget.onPetLiked(pet);
                  }
                },
                onSwipeStateChanged: widget.onSwipeStateChanged,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
