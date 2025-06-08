import 'package:flutter/material.dart';

enum SwipeType { left, right }

class SwipeIndicator extends StatelessWidget {
  const SwipeIndicator({super.key, required this.type, required this.opacity});

  final SwipeType type;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    bool isLike = type == SwipeType.right;

    return Center(
      child: AnimatedScale(
        scale: 0.8 + (opacity * 0.4),
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color:
                isLike
                    ? const Color(0xFF6C5CE7).withValues(alpha: 0.95)
                    : Colors.grey[600]!.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLike ? Icons.favorite : Icons.close,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isLike ? '간식주기' : '괜찮아요',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
