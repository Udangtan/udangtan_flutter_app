import 'package:flutter/material.dart';

class CommonBottomNavigation extends StatelessWidget {
  const CommonBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
      items: _buildNavItems(),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    var items = [
      {'icon': Icons.home, 'label': '홈'},
      {'icon': Icons.favorite, 'label': '간식함'},
      {'icon': Icons.chat, 'label': '채팅'},
      {'icon': Icons.person, 'label': '마이'},
    ];

    return items
        .map(
          (item) => BottomNavigationBarItem(
            icon: Icon(item['icon'] as IconData),
            label: item['label'] as String,
          ),
        )
        .toList();
  }
}
