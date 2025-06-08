import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/models/user.dart' as app_user;
import 'package:udangtan_flutter_app/pages/profile/pet_registration_page.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/pet_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_styles.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // 현재 세션과 사용자 정보 가져오기
      var session = await AuthService.getCurrentSession();
      var user = await AuthService.getCurrentUser();

      setState(() {
        _currentSession = session;
        _currentUser = user;
      });

      // 사용자의 펫 데이터 가져오기
      if (user != null) {
        List<Pet> pets = await PetService.getPetsByUser(user.id);
        setState(() {
          myPets = pets;
        });
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

        // 로그인 페이지로 이동
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(
        title: '마이페이지',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildPetsSection(),
            const SizedBox(height: 24),
            _buildMenuSection(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    // 카카오 세션에서 사용자 정보 가져오기
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
    var userLocation = '서울 강동구'; // 기본 위치

    return Container(
      margin: AppStyles.marginHorizontal20,
      padding: AppStyles.paddingAll20,
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: AppStyles.circleAvatarDecoration(AppColors.primary),
            child:
                profileImageUrl.isNotEmpty
                    ? ClipOval(
                      child: Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.person,
                              color: AppColors.textWhite,
                              size: 30,
                            ),
                      ),
                    )
                    : const Icon(
                      Icons.person,
                      color: AppColors.textWhite,
                      size: 30,
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
                const SizedBox(height: 4),
                Text(
                  '$userLocation · ${_currentSession != null ? "활동 중" : "로그인 필요"}',
                  style: const TextStyle(
                    fontSize: 12,
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
      padding: AppStyles.paddingAll20,
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 반려동물들 🐾',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: myPets.length + 1, // +1 for add button
              itemBuilder: (context, index) {
                if (index == myPets.length) {
                  return _buildAddPetButton();
                }
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == myPets.length - 1 ? 0 : 16,
                  ),
                  child: _buildPetItem(myPets[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetItem(Pet pet) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: AppStyles.circleAvatarDecoration(
              pet.species == '강아지' ? AppColors.dogColor : AppColors.catColor,
            ),
            child:
                pet.profileImages.isNotEmpty
                    ? ClipOval(
                      child: Image.network(
                        pet.profileImages.first,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.pets,
                              color: AppColors.textWhite,
                              size: 30,
                            ),
                      ),
                    )
                    : const Icon(
                      Icons.pets,
                      color: AppColors.textWhite,
                      size: 30,
                    ),
          ),
          const SizedBox(height: 8),
          Text(
            pet.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            pet.breed,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${pet.age}세',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetButton() {
    return SizedBox(
      width: 100,
      child: GestureDetector(
        onTap: () async {
          var result = await Navigator.push<Pet>(
            context,
            MaterialPageRoute(
              builder: (context) => const PetRegistrationPage(),
            ),
          );

          if (result != null) {
            _addNewPet(result);
          }
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: AppStyles.circleAvatarDecoration(
                AppColors.borderLight,
              ).copyWith(
                border: Border.all(
                  color: AppColors.borderDark,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.textSecondary,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '추가하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              '새 반려동물',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            const Text(
              '등록하기',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: AppStyles.marginHorizontal20,
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              '메뉴',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildMenuItem('🥖', '펫 건강 관리'),
          _buildMenuItem('📧', '펫 사진 앨범'),
          _buildMenuItem('🌻', '설정'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String emoji, String title) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: AppStyles.paddingSymmetric16_8.copyWith(
          left: 20,
          right: 20,
          top: 16,
          bottom: 16,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: AppStyles.marginHorizontal20,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: AppStyles.secondaryButtonStyle,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔒'),
            SizedBox(width: 8),
            Text(
              '로그아웃',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
