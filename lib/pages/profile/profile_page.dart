import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/models/user.dart' as app_user;
import 'package:udangtan_flutter_app/pages/profile/address_management_page.dart';
import 'package:udangtan_flutter_app/pages/profile/pet_registration_page.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/pet_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_styles.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';
import 'package:udangtan_flutter_app/shared/widgets/location_display_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  Session? _currentSession;
  app_user.User? _currentUser;
  List<Pet> myPets = [];
  bool _isLoading = true;
  bool _isPetsLoading = false;

  final GlobalKey<State<LocationDisplayWidget>> _locationWidgetKey =
      GlobalKey<State<LocationDisplayWidget>>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadProfile());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아올 때 펫 목록 갱신
      _loadUserPets();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 위젯이 다시 빌드될 때마다 펫 목록 갱신
    if (_currentUser != null) {
      _loadUserPets();
    }
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var currentUser = await AuthService.getCurrentUser();

      if (currentUser != null) {
        setState(() {
          _currentUser = currentUser;
          _isLoading = false;
        });
        await _loadUserPets();
      } else {
        if (mounted) {
          await AuthService.logout();
          if (mounted) {
            unawaited(Navigator.pushReplacementNamed(context, '/welcome'));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserPets() async {
    if (_currentUser == null) return;

    setState(() {
      _isPetsLoading = true;
    });

    try {
      var pets = await PetService.getPetsByUser(_currentUser!.id);
      if (mounted) {
        setState(() {
          myPets = pets;
          _isPetsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          myPets = [];
          _isPetsLoading = false;
        });
      }
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

        unawaited(
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/welcome', (route) => false),
        );
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

  Future<void> _navigateToAddressManagement() async {
    var userId = AuthService.getCurrentUserId();

    if (userId != null) {
      var result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (context) => const AddressManagementPage()),
      );

      // 주소 변경이 있었다면 페이지 새로고침
      if (result == true) {
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: CommonAppBar(title: '마이페이지', automaticallyImplyLeading: false),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

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
              Row(
                children: [
                  const Text(
                    '내 반려동물',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (myPets.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${myPets.length}마리',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              GestureDetector(
                onTap: _addPet,
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
          if (_isPetsLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: AppStyles.cardDecoration,
              child: const Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '반려동물 정보를 불러오는 중...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else if (myPets.isEmpty)
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
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: PageController(
                      viewportFraction: 0.85,
                      initialPage: 0,
                    ),
                    itemCount: myPets.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: _buildPetCard(myPets[index]),
                      );
                    },
                  ),
                ),
                if (myPets.length > 1) ...[
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swipe_left,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '좌우로 스와이프',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.swipe_right,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child:
                    pet.profileImages.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.network(
                            pet.profileImages.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.pets,
                                size: 30,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        )
                        : const Icon(
                          Icons.pets,
                          size: 30,
                          color: AppColors.primary,
                        ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                pet.gender == '수컷'
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.pink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pet.gender,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color:
                                  pet.gender == '수컷'
                                      ? Colors.blue[700]
                                      : Colors.pink[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.breed} • ${pet.age}살',
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.personality.isNotEmpty
                            ? pet.personality.first
                            : '성격',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.monitor_weight,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.weight != null ? '${pet.weight}kg' : '미등록',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        pet.isNeuteredComplete
                            ? Icons.check_circle
                            : Icons.help,
                        size: 16,
                        color:
                            pet.isNeuteredComplete
                                ? Colors.green
                                : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.isNeuteredComplete ? '중성화' : '미완료',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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

  Future<void> _addPet() async {
    if (_currentUser == null) {
      return;
    }

    try {
      var result = await Navigator.push<dynamic>(
        context,
        MaterialPageRoute(builder: (context) => const PetRegistrationPage()),
      );

      // Pet 객체가 반환되거나 true 값이 반환되면 펫 목록 새로고침
      if (result != null) {
        await _loadUserPets();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('새로운 반려동물이 등록되었습니다! 🎉'),
              backgroundColor: Color(0xFF6C5CE7),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('펫 추가 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
