import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/pages/chat/chat_list_page.dart';
import 'package:udangtan_flutter_app/pages/home/home_page.dart';
import 'package:udangtan_flutter_app/pages/snacks/snacks_page.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_bottom_navigation.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Pet> _likedPets = [];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onPetLiked(Pet pet) {
    setState(() {
      if (!_likedPets.any((p) => p.id == pet.id)) {
        _likedPets.add(pet);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return HomePage(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onPetLiked: _onPetLiked,
        );
      case 1:
        return SnacksPage(
          likedPets: _likedPets,
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
        );
      case 2:
        return ChatListPage(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
        );
      case 3:
        return _buildComingSoonPage('마이');
      default:
        return HomePage(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onPetLiked: _onPetLiked,
        );
    }
  }

  Widget _buildComingSoonPage(String pageName) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    pageName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.construction,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$pageName 페이지',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '곧 출시될 예정입니다!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
