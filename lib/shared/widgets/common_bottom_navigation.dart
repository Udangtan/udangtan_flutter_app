import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.bottomNavBackground,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: AppColors.bottomNavSelected,
        unselectedItemColor: AppColors.bottomNavUnselected,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _buildNavItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    var items = [
      {'icon': Icons.home, 'label': '홈'},
      {'icon': Icons.favorite, 'label': '간식함'},
      {'icon': Icons.chat, 'label': '채팅'},
      {'icon': Icons.person, 'label': '마이'},
      {'icon': Icons.location_on, 'label': '지도'},
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
