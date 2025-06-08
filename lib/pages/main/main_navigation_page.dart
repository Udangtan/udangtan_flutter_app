import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/pages/chat/chat_list_page.dart';
import 'package:udangtan_flutter_app/pages/home/home_page.dart';
import 'package:udangtan_flutter_app/pages/map/map_page.dart';
import 'package:udangtan_flutter_app/pages/profile/profile_page.dart';
import 'package:udangtan_flutter_app/pages/snacks/snacks_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final List<Pet> _likedPets = [];
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _isSwipeActive = false;
  double _swipeOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // 중앙 버튼 애니메이션
    if (index == 2) {
      _fabAnimationController.reset();
      _fabAnimationController.forward();
    }
  }

  void _onPetLiked(Pet pet) {
    setState(() {
      if (!_likedPets.any((p) => p.id == pet.id)) {
        _likedPets.add(pet);
      }
    });
  }

  void _onSwipeStateChanged(bool isActive, double opacity) {
    setState(() {
      _isSwipeActive = isActive;
      _swipeOpacity = opacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[50],
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomePage(
                currentNavIndex: _currentIndex,
                onNavTap: _onNavTap,
                onPetLiked: _onPetLiked,
                onSwipeStateChanged: _onSwipeStateChanged,
              ),
              SnacksPage(
                likedPets: _likedPets,
                currentNavIndex: _currentIndex,
                onNavTap: _onNavTap,
              ),
              MapPage(currentNavIndex: _currentIndex, onNavTap: _onNavTap),
              ChatListPage(currentNavIndex: _currentIndex, onNavTap: _onNavTap),
              ProfilePage(currentNavIndex: _currentIndex, onNavTap: _onNavTap),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(0, Icons.home_filled, '홈'),
                    _buildNavItem(1, Icons.favorite, '찜'),
                    _buildCenterNavItem(2, Icons.location_on, '내 주변'),
                    _buildNavItem(3, Icons.chat_bubble, '채팅'),
                    _buildNavItem(4, Icons.person, '프로필'),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 전체 화면 딤처리 오버레이 (앱바, 바텀 네비 포함)
        if (_isSwipeActive && _currentIndex == 0)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: _swipeOpacity * 0.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF6C5CE7).withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[600],
                size: isSelected ? 24 : 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[600],
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? 1.0 + (_fabAnimation.value * 0.1) : 1.0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isSelected
                          ? [const Color(0xFF6C5CE7), const Color(0xFF9E4BDE)]
                          : [Colors.grey[100]!, Colors.grey[200]!],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: const Color(
                              0xFF6C5CE7,
                            ).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 28,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
