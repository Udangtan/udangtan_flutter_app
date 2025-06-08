import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/features/home/widgets/pet_card.dart';
import 'package:udangtan_flutter_app/features/home/widgets/pet_card_stack.dart';
import 'package:udangtan_flutter_app/features/home/widgets/swipe_indicator.dart';
import 'package:udangtan_flutter_app/models/pet.dart';

class SwipeableCard extends StatefulWidget {
  const SwipeableCard({super.key, required this.pet, required this.onSwipe});

  final Pet pet;
  final Function(Pet, SwipeResult) onSwipe;

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard> {
  double _dragDistance = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onPanStart: (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _dragDistance += details.delta.dx;
        });
      },
      onPanEnd: (details) {
        var velocity = details.velocity.pixelsPerSecond.dx;
        var swipeThreshold = screenWidth * 0.25;

        if (_dragDistance.abs() > swipeThreshold || velocity.abs() > 500) {
          var result =
              _dragDistance > 0 ? SwipeResult.approve : SwipeResult.reject;
          widget.onSwipe(widget.pet, result);
        } else {
          setState(() {
            _dragDistance = 0;
            _isDragging = false;
          });
        }
      },
      child: Transform.translate(
        offset: Offset(_dragDistance, 0),
        child: Transform.rotate(
          angle: _dragDistance / 1000,
          child: Stack(
            children: [
              PetCard(
                pet: widget.pet,
                transform:
                    Matrix4.identity()
                      ..translate(_dragDistance, 0.0)
                      ..rotateZ(_dragDistance / 1000),
                isOnTop: true,
                onSwipe: () => widget.onSwipe(widget.pet, SwipeResult.approve),
              ),
              if (_isDragging) _buildSwipeIndicator(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeIndicator(double screenWidth) {
    var opacity = (_dragDistance.abs() / (screenWidth * 0.3)).clamp(0.0, 0.8);

    if (_dragDistance > 20) {
      return SwipeIndicator(type: SwipeType.right, opacity: opacity);
    } else if (_dragDistance < -20) {
      return SwipeIndicator(type: SwipeType.left, opacity: opacity);
    }

    return const SizedBox.shrink();
  }
}
