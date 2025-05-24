import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_bottom_navigation.dart';

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

class _SnacksPageState extends State<SnacksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 샘플 받은 친구들 데이터 (나중에 실제 데이터로 교체)
  List<Pet> get receivedPets => Pet.samplePets.take(2).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: const CommonAppBar(
          title: '간식함',
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildTabSection(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPetGrid(
                      receivedPets,
                      '아직 받은 간식이 없어요',
                      '친구들이 간식을 보내주기를 기다려보세요!',
                    ),
                    _buildPetGrid(
                      widget.likedPets,
                      '아직 간식을 준 친구가 없어요',
                      '홈에서 친구들에게 간식을 주어보세요!',
                    ),
                  ],
                ),
              ),
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

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.purple,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [Tab(text: '받은 친구들'), Tab(text: '보낸 친구들')],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPetGrid(
    List<Pet> pets,
    String emptyTitle,
    String emptySubtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child:
          pets.isEmpty
              ? _buildEmptyState(emptyTitle, emptySubtitle)
              : _buildPetGridView(pets),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPetGridView(List<Pet> pets) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return _buildPetGridItem(pets[index]);
      },
    );
  }

  Widget _buildPetGridItem(Pet pet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              pet.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: AppColors.cardBackground,
                    child: const Center(
                      child: Icon(Icons.pets, size: 60, color: Colors.white70),
                    ),
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${pet.name} ${pet.age}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.favorite, color: Colors.red, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
