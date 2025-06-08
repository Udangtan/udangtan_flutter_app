import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/models/pet.dart';

class PetCard extends StatefulWidget {
  const PetCard({
    super.key,
    required this.pet,
    required this.transform,
    required this.isOnTop,
    required this.onSwipe,
  });

  final Pet pet;
  final Matrix4 transform;
  final bool isOnTop;
  final VoidCallback onSwipe;

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> with TickerProviderStateMixin {
  bool _imageLoaded = false;
  late AnimationController _skeletonController;
  late Animation<double> _skeletonAnimation;

  @override
  void initState() {
    super.initState();
    _skeletonController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _skeletonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _skeletonController, curve: Curves.easeInOut),
    );
    _skeletonController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _skeletonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: widget.transform,
      child: GestureDetector(
        onTap: widget.onSwipe,
        child: SizedBox(
          width: 340,
          height: 500,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child:
                    _imageLoaded ? _buildMainImage() : _buildSkeletonLoader(),
              ),
              if (_imageLoaded) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.pet.locationCity ?? '서울'} ${widget.pet.locationDistrict ?? '강남구'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.pet.species,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.pet.name}, ${widget.pet.age}세',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.pet.personality.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children:
                              widget.pet.personality
                                  .take(3)
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      const SizedBox(height: 16),
                      if (widget.pet.description != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.pet.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainImage() {
    return widget.pet.profileImages.isNotEmpty
        ? Image.network(
          widget.pet.profileImages.first,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _imageLoaded = true;
                  });
                  _skeletonController.stop();
                }
              });
              return child;
            }
            return _buildSkeletonLoader();
          },
          errorBuilder: (context, error, stackTrace) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _imageLoaded = true;
                });
                _skeletonController.stop();
              }
            });
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.pets, size: 80, color: Colors.grey),
              ),
            );
          },
        )
        : Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.pets, size: 80, color: Colors.grey),
          ),
        );
  }

  Widget _buildSkeletonLoader() {
    return AnimatedBuilder(
      animation: _skeletonAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _skeletonAnimation.value, 0.0),
              end: Alignment(1.0 + 2.0 * _skeletonAnimation.value, 0.0),
              colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '이미지 로딩 중...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
