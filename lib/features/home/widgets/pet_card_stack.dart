import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/features/home/widgets/pet_card.dart';
import 'package:udangtan_flutter_app/features/home/widgets/swipe_indicator.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/services/pet_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';

class PetCardStack extends StatefulWidget {
  const PetCardStack({
    super.key,
    required this.onSwipe,
    this.onSwipeStateChanged,
  });

  final Function(Pet, SwipeResult) onSwipe;
  final Function(bool isActive, double opacity)? onSwipeStateChanged;

  @override
  PetCardStackState createState() => PetCardStackState();
}

class PetCardStackState extends State<PetCardStack>
    with TickerProviderStateMixin {
  static const int maxCards = 5;
  List<Pet> _cardStack = [];
  List<Pet> _allPets = [];
  int _currentIndex = 0;
  double _position = 0;
  bool _isDragging = false;
  bool _isLoading = true;

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

  Future<void> _initializeCards() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _allPets = await PetService.getPetsNearby(radiusKm: 5.0);

      if (_allPets.isNotEmpty) {
        _cardStack = List.from(_allPets.take(maxCards));
      } else {
        _allPets = [];
        _cardStack = [];
      }
      _currentIndex = 0;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      try {
        _allPets = await PetService.getAllPets();
        if (_allPets.isNotEmpty) {
          _cardStack = List.from(_allPets.take(maxCards));
        } else {
          _allPets = [];
          _cardStack = [];
        }
      } catch (e2) {
        _allPets = [];
        _cardStack = [];
      }
      _currentIndex = 0;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void simulateSwipe(SwipeResult result) {
    if (_cardStack.isEmpty || _animationController.isAnimating || !mounted)
      return;
    _handleSwipe(result);
  }

  Future<void> refreshCards() async {
    if (!mounted) return;
    await _initializeCards();
  }

  Future<void> refreshPets({bool forceRefresh = false}) async {
    if (!mounted) return;

    if (forceRefresh) {
      setState(() {
        _allPets.clear();
        _cardStack.clear();
        _currentIndex = 0;
        _isLoading = true;
      });
    }

    await _initializeCards();
  }

  void _handleSwipe(SwipeResult result) {
    if (_cardStack.isEmpty || !mounted) return;

    var currentPet = _cardStack[_currentIndex];
    widget.onSwipe(currentPet, result);

    setState(() {
      _position = 0;
      _isDragging = false;
    });

    widget.onSwipeStateChanged?.call(false, 0.0);
    _allPets.removeWhere((pet) => pet.id == currentPet.id);

    if (_allPets.isEmpty) {
      if (mounted) {
        setState(() {
          _cardStack.clear();
          _currentIndex = 0;
        });
      }
      return;
    }

    _animateCardRemoval();
  }

  void _animateCardRemoval() {
    if (!mounted) return;

    _animationController.forward().then((_) {
      if (!mounted) return;

      setState(() {
        if (_cardStack.isNotEmpty) {
          _cardStack.removeAt(_currentIndex % _cardStack.length);
        }

        if (_allPets.length > _cardStack.length &&
            _cardStack.length < maxCards) {
          var nextPetIndex = _cardStack.length;
          if (nextPetIndex < _allPets.length) {
            _cardStack.add(_allPets[nextPetIndex]);
          }
        }

        if (_currentIndex >= _cardStack.length && _cardStack.isNotEmpty) {
          _currentIndex = 0;
        }

        if (_allPets.isEmpty || _cardStack.isEmpty) {
          _cardStack.clear();
          _currentIndex = 0;
        }
      });
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
        ),
      );
    }

    if (_cardStack.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.pets, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              '5km 반경 내 펫이 없습니다',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '반경을 넓히거나 다른 지역의\n펫 친구들을 찾아보세요!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => refreshPets(),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  '새로고침',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    var size = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(
          _cardStack.length == 1
              ? 1
              : ((_cardStack.length <= maxCards)
                  ? _cardStack.length
                  : maxCards),
          (index) {
            var cardIndex = (_currentIndex + index) % _cardStack.length;

            if (cardIndex >= _cardStack.length) {
              return const SizedBox.shrink();
            }

            var pet = _cardStack[cardIndex];
            var isTopCard = index == 0;

            var scale = 0.95 - (index * 0.05);
            var offsetY = -index * 15.0;
            var offsetX = index * 3.0;
            var rotation = 0.0;
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
                  var nextRotation = 0.0;
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
              child: () {
                return isTopCard
                    ? _buildTopCard(pet, size, index)
                    : _buildBackCard(pet, index);
              }(),
            );
          },
        ).reversed,
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
        if (!mounted) return;
        setState(() {
          _isDragging = true;
        });
        widget.onSwipeStateChanged?.call(true, 0.0);
      },
      onPanUpdate: (details) {
        if (!mounted) return;
        setState(() {
          _position += details.delta.dx;
        });
        var opacity = (_position.abs() / (size.width * 0.3)).clamp(0.0, 0.8);
        widget.onSwipeStateChanged?.call(true, opacity);
      },
      onPanEnd: (details) {
        if (!mounted) return;

        var swipeThreshold = size.width * 0.3;

        if (_position.abs() > swipeThreshold) {
          var result = _position > 0 ? SwipeResult.approve : SwipeResult.reject;
          _handleSwipe(result);
        } else {
          setState(() {
            _position = 0;
            _isDragging = false;
          });
          widget.onSwipeStateChanged?.call(false, 0.0);
        }
      },
      child: Transform.translate(
        offset: Offset(_position, 0),
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: PetCard(
              pet: pet,
              transform:
                  Matrix4.identity()
                    ..translate(_position, 0.0)
                    ..rotateZ(rotation)
                    ..scale(scale),
              isOnTop: true,
              onSwipe: () {},
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(Pet pet, int index) {
    return IgnorePointer(
      child: PetCard(
        pet: pet,
        transform: Matrix4.identity(),
        isOnTop: false,
        onSwipe: () {},
      ),
    );
  }
}

enum SwipeResult { approve, reject }
