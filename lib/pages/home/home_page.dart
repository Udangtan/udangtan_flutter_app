import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/features/home/widgets/address_registration_prompt.dart';
import 'package:udangtan_flutter_app/features/home/widgets/pet_card_stack.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/pages/profile/address_management_page.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/location_service.dart';
import 'package:udangtan_flutter_app/services/pet_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';
import 'package:udangtan_flutter_app/shared/widgets/location_display_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.currentNavIndex,
    required this.onNavTap,
    required this.onPetLiked,
  });

  final int currentNavIndex;
  final Function(int) onNavTap;
  final Function(Pet) onPetLiked;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final GlobalKey<PetCardStackState> _petCardStackKey =
      GlobalKey<PetCardStackState>();
  int _lastNavIndex = -1;
  int _locationWidgetRefreshKey = 0;
  bool _hasAddress = true;
  bool _isCheckingAddress = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastNavIndex = widget.currentNavIndex;
    _checkAddressRegistration();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    if (state == AppLifecycleState.resumed && widget.currentNavIndex == 0) {
      _refreshPets();
    }
  }

  Future<void> _refreshPets() async {
    await _petCardStackKey.currentState?.refreshPets(forceRefresh: true);
  }

  Future<void> _refreshCardsAfterSwipe() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _petCardStackKey.currentState?.refreshCards();
  }

  Future<void> _navigateToAddressManagement() async {
    var userId = AuthService.getCurrentUserId();

    if (userId != null) {
      var result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (context) => const AddressManagementPage()),
      );

      if (result == true) {
        setState(() {
          _locationWidgetRefreshKey++;
        });
        await _refreshPets();
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

  void _checkAddressRegistration() async {
    var userId = AuthService.getCurrentUserId();
    if (userId == null) {
      setState(() {
        _hasAddress = false;
        _isCheckingAddress = false;
      });
      return;
    }

    try {
      var hasAddress = await LocationService.hasUserRegisteredAddress(userId);
      setState(() {
        _hasAddress = hasAddress;
        _isCheckingAddress = false;
      });
    } catch (e) {
      setState(() {
        _hasAddress = false;
        _isCheckingAddress = false;
      });
    }
  }

  void _onAddressRegistered() async {
    setState(() {
      _locationWidgetRefreshKey++;
    });
    _checkAddressRegistration();
    await Future.delayed(const Duration(milliseconds: 500));
    await _refreshPets();
  }

  void _handleSwipe(Pet pet, SwipeResult result) async {
    try {
      var currentUserId = AuthService.getCurrentUserId();
      if (currentUserId == null || pet.id == null) return;

      bool success = false;
      String message = '';

      if (result == SwipeResult.approve) {
        success = await PetService.likePet(currentUserId, pet.id!);

        if (success) {
          message = '${pet.name}에게 간식을 주었습니다! 🍖';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          widget.onPetLiked(pet);
        } else {
          message = '이미 간식을 준 펫입니다';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else if (result == SwipeResult.reject) {
        success = await PetService.rejectPet(currentUserId, pet.id!);

        if (success) {
          message = '${pet.name}을(를) 건너뛰었습니다';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.grey,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        } else {
          message = '이미 건너뛴 펫입니다';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }

      await _refreshCardsAfterSwipe();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                    child:
                        _hasAddress
                            ? LocationDisplayWidget(
                              key: ValueKey(_locationWidgetRefreshKey),
                              padding: EdgeInsets.zero,
                              showIcon: false,
                            )
                            : const Text(
                              '주소를 등록해주세요',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                  ),
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child:
                _isCheckingAddress
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                    : !_hasAddress
                    ? AddressRegistrationPrompt(
                      onAddressRegistered: _onAddressRegistered,
                    )
                    : Center(
                      child: PetCardStack(
                        key: _petCardStackKey,
                        onSwipe: _handleSwipe,
                      ),
                    ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
