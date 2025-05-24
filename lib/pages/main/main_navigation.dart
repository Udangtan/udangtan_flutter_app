import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/features/chat/pages/chat_list_page.dart';
import 'package:udangtan_flutter_app/features/profile/pages/profile_page.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/pages/home/home_page.dart';
import 'package:udangtan_flutter_app/pages/snacks/snacks_page.dart';

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
        return ProfilePage(currentNavIndex: _currentIndex, onNavTap: _onNavTap);
      default:
        return HomePage(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onPetLiked: _onPetLiked,
        );
    }
  }
}
