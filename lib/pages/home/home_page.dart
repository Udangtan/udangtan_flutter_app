import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/features/home/widgets/pet_card_stack.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_bottom_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.currentNavIndex,
    required this.onNavTap,
    required this.onPetLiked,
  });

  final int currentNavIndex;
  final Function(int) onNavTap;
  final Function(Pet) onPetLiked;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: const CommonAppBar(
          title: '홈',
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: _buildCardStack(),
          ),
        ),
        bottomNavigationBar: CommonBottomNavigation(
          currentIndex: widget.currentNavIndex,
          onTap: widget.onNavTap,
        ),
      ),
    );
  }

  Widget _buildCardStack() {
    return PetCardStack(
      onSwipe: (pet, result) {
        if (result == SwipeResult.approve) {
          widget.onPetLiked(pet);
        }
      },
    );
  }
}
