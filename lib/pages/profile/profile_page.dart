import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/pages/profile/pet_registration_page.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/styles/app_styles.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_bottom_navigation.dart';

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
  List<Pet> myPets = List.from(Pet.myPets);

  void _addNewPet(Pet newPet) {
    setState(() {
      myPets.add(newPet);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
        bottomNavigationBar: CommonBottomNavigation(
          currentIndex: widget.currentNavIndex,
          onTap: widget.onNavTap,
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '김펫프렌드',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'petfriend@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '서울 강동구 · 활동 휴면',
                  style: TextStyle(
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
              pet.type == '강아지' ? AppColors.dogColor : AppColors.catColor,
            ),
            child:
                pet.imageUrl.isNotEmpty
                    ? ClipOval(
                      child: Image.asset(
                        pet.imageUrl,
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
            pet.breed ?? '품종 미등록',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${pet.ageRange ?? '나이 미등록'} ${pet.gender ?? ''}',
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
              child: Icon(Icons.add, color: AppColors.textSecondary, size: 30),
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
            Text(
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
      onTap: () {
        // TODO: Add navigation to respective pages
      },
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
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
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
        onPressed: () {
          // TODO: Add logout functionality
        },
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
