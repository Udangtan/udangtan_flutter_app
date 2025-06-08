import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/features/home/widgets/pet_card_stack.dart';
import 'package:udangtan_flutter_app/models/pet.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.currentNavIndex,
    required this.onNavTap,
    required this.onPetLiked,
    this.onSwipeStateChanged,
  });

  final int currentNavIndex;
  final Function(int) onNavTap;
  final Function(Pet) onPetLiked;
  final Function(bool isActive, double opacity)? onSwipeStateChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<PetCardStackState> _cardStackKey =
      GlobalKey<PetCardStackState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(child: _buildCardStack()),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardStack() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 800, maxWidth: 400),
      child: PetCardStack(
        key: _cardStackKey,
        onSwipe: (pet, result) {
          if (result == SwipeResult.approve) {
            widget.onPetLiked(pet);
            _showLikeAnimation();
          }
        },
        onSwipeStateChanged: widget.onSwipeStateChanged,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              text: '괜찮아요',
              backgroundColor: Colors.white,
              textColor: Colors.grey[700]!,
              borderColor: Colors.grey[300]!,
              onTap:
                  () => _cardStackKey.currentState?.simulateSwipe(
                    SwipeResult.reject,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              text: '간식주기',
              backgroundColor: const Color(0xFF6C5CE7),
              textColor: Colors.white,
              borderColor: const Color(0xFF6C5CE7),
              onTap:
                  () => _cardStackKey.currentState?.simulateSwipe(
                    SwipeResult.approve,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showLikeAnimation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) {
        return const Center(
          child: Icon(Icons.favorite, color: Colors.red, size: 100),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
