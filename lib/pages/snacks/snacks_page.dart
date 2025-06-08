import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/services/pet_service.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';

class SnacksPage extends StatefulWidget {
  const SnacksPage({
    super.key,
    required this.likedPets,
    required this.currentNavIndex,
    required this.onNavTap,
  });

  final List<Pet> likedPets;
  final int currentNavIndex;
  final Function(int) onNavTap;

  @override
  State<SnacksPage> createState() => _SnacksPageState();
}

class _SnacksPageState extends State<SnacksPage> {
  List<Pet> _likedPets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedPets();
  }

  Future<void> _loadLikedPets() async {
    try {
      var user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        var likedPets = await PetService.getLikedPets(user.id);
        setState(() {
          _likedPets = likedPets;
          _isLoading = false;
        });
      } else {
        setState(() {
          _likedPets = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _likedPets = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '간식함',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadLikedPets,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '간식',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          '보낸 친구들',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _likedPets.isEmpty
                            ? _buildEmptyState()
                            : _buildPetGrid(),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '새로운 친구들을 만나보세요',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _likedPets.length,
      itemBuilder: (context, index) {
        return _buildPetCard(_likedPets[index]);
      },
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 메인 이미지
            pet.profileImages.isNotEmpty
                ? Image.network(
                  pet.profileImages.first,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.pets, size: 40, color: Colors.grey),
                        ),
                      ),
                )
                : Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.pets, size: 40, color: Colors.grey),
                  ),
                ),

            // 그라데이션 오버레이
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),

            // 좋아요 아이콘 (우상단)
            const Positioned(
              top: 12,
              right: 12,
              child: Icon(Icons.favorite, color: Colors.white, size: 20),
            ),

            // 하단 정보
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${pet.name}, ${pet.age}세',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (pet.personality.isNotEmpty)
                    Text(
                      pet.personality.first,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
