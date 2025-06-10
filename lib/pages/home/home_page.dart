import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/features/home/widgets/pet_card_stack.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/pages/profile/address_management_page.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';
import 'package:udangtan_flutter_app/shared/widgets/location_display_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.currentNavIndex,
    required this.onNavTap,
    required this.onPetLiked,
    required this.onSwipeStateChanged,
  });

  final int currentNavIndex;
  final Function(int) onNavTap;
  final Function(Pet) onPetLiked;
  final Function(bool isActive, double opacity) onSwipeStateChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final GlobalKey<PetCardStackState> _petCardStackKey =
      GlobalKey<PetCardStackState>();
  int _lastNavIndex = -1;
  int _locationWidgetRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastNavIndex = widget.currentNavIndex;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 홈 탭으로 돌아올 때마다 펫 정보 새로고침
    if (oldWidget.currentNavIndex != widget.currentNavIndex &&
        widget.currentNavIndex == 0 &&
        _lastNavIndex != 0) {
      _refreshPets();
    }
    _lastNavIndex = widget.currentNavIndex;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 포그라운드로 돌아올 때 펫 정보 새로고침
    if (state == AppLifecycleState.resumed && widget.currentNavIndex == 0) {
      _refreshPets();
    }
  }

  void _refreshPets() {
    // PetCardStack의 refreshPets 메서드 호출
    _petCardStackKey.currentState?.refreshPets();
  }

  Future<void> _navigateToAddressManagement() async {
    var userId = AuthService.getCurrentUserId();

    if (userId != null) {
      var result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (context) => const AddressManagementPage()),
      );

      // 주소 변경이 있었다면 위치 위젯과 펫 정보 새로고침
      if (result == true) {
        setState(() {
          _locationWidgetRefreshKey++; // LocationDisplayWidget 강제 새로고침
        });
        _refreshPets(); // 펫 정보도 새로고침
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(
        title: '우당탕',
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: _navigateToAddressManagement,
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: LocationDisplayWidget(
                      key: ValueKey(_locationWidgetRefreshKey),
                      padding: EdgeInsets.zero,
                      showIcon: false,
                    ),
                  ),
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: PetCardStack(
                key: _petCardStackKey,
                onSwipe: (pet, result) {
                  if (result == SwipeResult.approve) {
                    widget.onPetLiked(pet);
                  }
                },
                onSwipeStateChanged: widget.onSwipeStateChanged,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
