import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/models/user.dart' as app_user;
import 'package:udangtan_flutter_app/pages/profile/address_management_page.dart';
import 'package:udangtan_flutter_app/pages/profile/pet_registration_complete_page.dart';
import 'package:udangtan_flutter_app/pages/profile/pet_registration_page.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/location_service.dart';
import 'package:udangtan_flutter_app/services/pet_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_styles.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';
import 'package:udangtan_flutter_app/shared/widgets/location_display_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.currentNavIndex,
    required this.onNavTap,
  });

  final int currentNavIndex;
  final Function(int) onNavTap;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Pet> myPets = [];
  Session? _currentSession;
  app_user.User? _currentUser;
  final GlobalKey<State<LocationDisplayWidget>> _locationWidgetKey =
      GlobalKey<State<LocationDisplayWidget>>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      var session = await AuthService.getCurrentSession();
      var user = await AuthService.getCurrentUser();

      setState(() {
        _currentSession = session;
        _currentUser = user;
      });

      if (user != null) {
        await Future.wait([_loadPets(user.id), _loadDefaultAddress(user.id)]);
      } else {
        setState(() {
          myPets = [];
        });
      }
    } catch (e) {
      setState(() {
        myPets = [];
      });
    }
  }

  Future<void> _loadPets(String userId) async {
    try {
      List<Pet> pets = await PetService.getPetsByUser(userId);
      setState(() {
        myPets = pets;
      });
    } catch (e) {
      setState(() {
        myPets = [];
      });
    }
  }

  Future<void> _loadDefaultAddress(String userId) async {
    try {
      await LocationService.getDefaultAddress(userId);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃되었습니다.'),
            backgroundColor: Color(0xFF6C5CE7),
            duration: Duration(seconds: 2),
          ),
        );

        await Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _addNewPet(Pet newPet) {
    setState(() {
      myPets.add(newPet);
    });
  }

  Future<void> _navigateToAddressManagement() async {
    var userId = AuthService.getCurrentUserId();

    if (userId != null) {
      var result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddressManagementPage()),
      );

      if (result != null) {
        await _loadDefaultAddress(userId);
        setState(() {});
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
        title: '마이페이지',
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LocationDisplayWidget(
                    key: _locationWidgetKey,
                    showManageButton: true,
                    onManageTap: _navigateToAddressManagement,
                    padding: EdgeInsets.zero,
                    showIcon: false,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildPetsSection(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    var userMetadata = _currentSession?.user.userMetadata;
    var userName =
        _currentUser?.name ??
        (userMetadata?['name'] as String?) ??
        (userMetadata?['full_name'] as String?) ??
        '사용자';
    var userEmail =
        _currentUser?.email ??
        (userMetadata?['email'] as String?) ??
        'email@example.com';
    var profileImageUrl =
        _currentUser?.profileImageUrl ??
        (userMetadata?['avatar_url'] as String?) ??
        '';

    return Container(
      margin: AppStyles.marginHorizontal20,
      padding: AppStyles.paddingAll20,
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: AppStyles.circleAvatarDecoration(AppColors.borderLight),
            child:
                profileImageUrl.isNotEmpty
                    ? ClipOval(
                      child: Image.network(
                        profileImageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 30,
                            color: AppColors.textSecondary,
                          );
                        },
                      ),
                    )
                    : const Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.textSecondary,
                    ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsSection() {
    return Container(
      margin: AppStyles.marginHorizontal20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '내 반려동물',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (_currentUser != null) {
                    var result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PetRegistrationPage(),
                      ),
                    );

                    if (result is Pet) {
                      _addNewPet(result);

                      if (mounted) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PetRegistrationCompletePage(pet: result),
                          ),
                        );
                      }
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        '추가',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (myPets.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: AppStyles.cardDecoration,
              child: const Column(
                children: [
                  Icon(Icons.pets, size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    '등록된 반려동물이 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '첫 번째 반려동물을 등록해보세요!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...myPets.map((pet) => _buildPetCard(pet)),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: AppStyles.circleAvatarDecoration(AppColors.borderLight),
            child:
                pet.profileImages.isNotEmpty
                    ? ClipOval(
                      child: Image.network(
                        pet.profileImages.first,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.pets,
                            size: 24,
                            color: AppColors.textSecondary,
                          );
                        },
                      ),
                    )
                    : const Icon(
                      Icons.pets,
                      size: 24,
                      color: AppColors.textSecondary,
                    ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.species} • ${pet.breed}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: AppStyles.marginHorizontal20,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 16,
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
