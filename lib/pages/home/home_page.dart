import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_bottom_navigation.dart';
import 'package:udangtan_flutter_app/shared/widgets/pet_card_stack.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '홈',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                ],
              ),
            ),
            Expanded(child: _buildCardStack()),
          ],
        ),
      ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: widget.currentNavIndex,
        onTap: widget.onNavTap,
      ),
    );
  }

  Widget _buildCardStack() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PetCardStack(
        onSwipe: (pet, result) {
          if (result == SwipeResult.approve) {
            widget.onPetLiked(pet);
          }
        },
      ),
    );
  }
}
