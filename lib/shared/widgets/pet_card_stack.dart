import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/widgets/pet_card.dart';
import 'package:udangtan_flutter_app/shared/widgets/swipe_indicator.dart';

class PetCardStack extends StatefulWidget {
  const PetCardStack({super.key, required this.onSwipe});

  final Function(Pet, SwipeResult) onSwipe;

  @override
  State<PetCardStack> createState() => _PetCardStackState();
}

class _PetCardStackState extends State<PetCardStack>
    with TickerProviderStateMixin {
  static const int maxCards = 5;
  List<Pet> _cardStack = [];
  int _currentIndex = 0;
  double _position = 0;
  bool _isDragging = false;

  late AnimationController _animationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _nextCardAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCards();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _nextCardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _initializeCards() {
    var allPets = Pet.samplePets;
    _cardStack = List.from(allPets.take(maxCards));
    _currentIndex = 0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSwipe(SwipeResult result) {
    if (_cardStack.isEmpty) return;

    var currentPet = _cardStack[_currentIndex];
    widget.onSwipe(currentPet, result);

    setState(() {
      _position = 0;
      _isDragging = false;
    });

    _animateCardRemoval();
  }

  void _animateCardRemoval() {
    _animationController.forward().then((_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _cardStack.length;
        var allPets = Pet.samplePets;
        var nextPetIndex = (_currentIndex + maxCards - 1) % allPets.length;
        if (_cardStack.length == maxCards) {
          _cardStack[(_currentIndex + maxCards - 1) % maxCards] =
              allPets[nextPetIndex];
        }
      });
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(maxCards, (index) {
          var cardIndex = (_currentIndex + index) % _cardStack.length;
          if (cardIndex >= _cardStack.length) return const SizedBox.shrink();

          var pet = _cardStack[cardIndex];
          var isTopCard = index == 0;

          var scale = 0.95 - (index * 0.05);
          var offsetY = -index * 15.0;
          var offsetX = index * 3.0;
          var rotation = (index * 0.015) * (index % 2 == 0 ? 1 : -1);
          var opacity = 1.0 - (index * 0.12);

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (isTopCard && _animationController.isAnimating) {
                var animatedScale = scale * (1 - _cardAnimation.value);
                var animatedOpacity = opacity * (1 - _cardAnimation.value);
                return Transform.scale(
                  scale: animatedScale,
                  child: Opacity(opacity: animatedOpacity, child: child),
                );
              }

              if (!isTopCard && _animationController.isAnimating) {
                var nextScale = 0.95 - ((index - 1) * 0.05);
                var nextOffsetY = -(index - 1) * 15.0;
                var nextOffsetX = (index - 1) * 3.0;
                var nextRotation =
                    ((index - 1) * 0.015) * ((index - 1) % 2 == 0 ? 1 : -1);
                var nextOpacity = 1.0 - ((index - 1) * 0.12);

                var animatedScale =
                    scale + (nextScale - scale) * _nextCardAnimation.value;
                var animatedOffsetY =
                    offsetY +
                    (nextOffsetY - offsetY) * _nextCardAnimation.value;
                var animatedOffsetX =
                    offsetX +
                    (nextOffsetX - offsetX) * _nextCardAnimation.value;
                var animatedRotation =
                    rotation +
                    (nextRotation - rotation) * _nextCardAnimation.value;
                var animatedOpacity =
                    opacity +
                    (nextOpacity - opacity) * _nextCardAnimation.value;

                return Transform.translate(
                  offset: Offset(animatedOffsetX, animatedOffsetY),
                  child: Transform.rotate(
                    angle: animatedRotation,
                    child: Transform.scale(
                      scale: animatedScale,
                      child: Opacity(
                        opacity: animatedOpacity.clamp(0.0, 1.0),
                        child: child,
                      ),
                    ),
                  ),
                );
              }

              return Transform.translate(
                offset: Offset(offsetX, offsetY),
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child:
                isTopCard
                    ? _buildTopCard(pet, size, index)
                    : _buildBackCard(pet, index),
          );
        }).reversed,

        if (_isDragging)
          Positioned.fill(
            child: Stack(
              children: [
                if (_position < -20)
                  SwipeIndicator(
                    type: SwipeType.left,
                    opacity: (_position.abs() / (size.width * 0.3)).clamp(
                      0.1,
                      0.8,
                    ),
                  ),
                if (_position > 20)
                  SwipeIndicator(
                    type: SwipeType.right,
                    opacity: (_position / (size.width * 0.3)).clamp(0.1, 0.8),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTopCard(Pet pet, Size size, int index) {
    var rotation = _position / 1000;
    var scale = 1.0 - (_position.abs() / size.width * 0.1).clamp(0.0, 0.1);

    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _position += details.delta.dx;
        });
      },
      onPanEnd: (details) {
        var swipeThreshold = size.width * 0.3;

        if (_position.abs() > swipeThreshold) {
          var result = _position > 0 ? SwipeResult.approve : SwipeResult.reject;
          _handleSwipe(result);
        } else {
          setState(() {
            _position = 0;
            _isDragging = false;
          });
        }
      },
      child: Transform.translate(
        offset: Offset(_position, 0),
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(scale: scale, child: PetCard(pet: pet)),
        ),
      ),
    );
  }

  Widget _buildBackCard(Pet pet, int index) {
    return IgnorePointer(child: PetCard(pet: pet));
  }
}

enum SwipeResult { approve, reject }
