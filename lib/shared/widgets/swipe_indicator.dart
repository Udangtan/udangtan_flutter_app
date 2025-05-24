import 'package:flutter/material.dart';

enum SwipeType { left, right }

class SwipeIndicator extends StatelessWidget {
  const SwipeIndicator({super.key, required this.type, required this.opacity});

  final SwipeType type;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    var gradient =
        type == SwipeType.left
            ? LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.red.withValues(alpha: opacity),
                Colors.transparent,
              ],
            )
            : LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                Colors.green.withValues(alpha: opacity),
                Colors.transparent,
              ],
            );

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Center(
        child: Text(
          type == SwipeType.left ? '괜찮아요' : '간식주기',
          style: TextStyle(
            color: Colors.white.withValues(alpha: opacity),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
