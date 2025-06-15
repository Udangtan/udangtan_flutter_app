import 'dart:async';

import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/pages/chat/chat_detail_page.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/chat_service.dart';
import 'package:udangtan_flutter_app/services/pet_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';

class SnacksPage extends StatefulWidget {
  const SnacksPage({super.key});

  @override
  State<SnacksPage> createState() => _SnacksPageState();
}

class _SnacksPageState extends State<SnacksPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  List<Pet> _likedPets = [];
  bool _isLoading = true;
  String? _currentUserId;
  final bool _isPageVisible = true;

  @override
  bool get wantKeepAlive => true; // 페이지 상태 유지

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLikedPets();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isPageVisible) {
      _loadLikedPets();
    }
  }

  void refreshData() {
    if (mounted) {
      _loadLikedPets();
    }
  }

  Future<void> _loadLikedPets() async {
    setState(() => _isLoading = true);

    try {
      _currentUserId = AuthService.getCurrentUserId();
      if (_currentUserId != null) {
        var pets = await PetService.getLikedPets();
        setState(() {
          _likedPets = pets;
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('간식함 로드 실패: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _removeLike(Pet pet) async {
    if (_currentUserId == null || pet.id == null) return;

    try {
      await PetService.unlikePet(_currentUserId!, pet.id!);
      setState(() {
        _likedPets.removeWhere((p) => p.id == pet.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pet.name}을(를) 간식함에서 제거했습니다'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('제거 실패: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _openChatWithPet(Pet pet) async {
    if (_currentUserId == null || pet.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('채팅을 시작할 수 없습니다'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 자기 자신의 펫인지 확인 (ownerId가 있는 경우)
    if (pet.ownerId == _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('자신의 펫과는 채팅할 수 없습니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // 로딩 표시
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
      ),
    );

    try {
      var chatRoom = await ChatService.findOrCreatePetChatRoom(
        currentUserId: _currentUserId!,
        targetPetId: pet.id!,
      );

      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      if (chatRoom != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(chatRoom: chatRoom),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('채팅방을 생성할 수 없습니다'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        String errorMessage = '채팅방 생성 실패';

        if (e.toString().contains('자신의 펫과는 채팅할 수 없습니다')) {
          errorMessage = '자신의 펫과는 채팅할 수 없습니다';
        } else if (e.toString().contains('등록된 펫이 없습니다')) {
          errorMessage = '등록된 펫이 없습니다. 먼저 펫을 등록해주세요.';
        } else if (e.toString().contains('column') &&
            e.toString().contains('does not exist')) {
          errorMessage = '데이터베이스 설정 오류입니다. 관리자에게 문의하세요.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(
        title: '간식함',
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
              : _likedPets.isEmpty
              ? _buildEmptyState()
              : _buildPetGrid(),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadLikedPets,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  '아직 간식을 준 펫이 없어요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '홈에서 마음에 드는 펫에게\n간식을 주어보세요! 🍖',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '↓ 아래로 당겨서 새로고침 ↓',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetGrid() {
    return RefreshIndicator(
      onRefresh: _loadLikedPets,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _likedPets.length,
          itemBuilder: (context, index) {
            return _buildPetCard(_likedPets[index]);
          },
        ),
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () => _openChatWithPet(pet),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 펫 이미지
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: _buildPetImage(pet),
              ),
            ),
            // 펫 정보
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // 이벤트 버블링 방지
                            _removeLike(pet);
                          },
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.species} • ${pet.age}살',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    if (pet.ownerName != null)
                      Text(
                        '주인: ${pet.ownerName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (pet.ownerName != null) const SizedBox(height: 2),
                    if (pet.ownerAddress != null)
                      Text(
                        pet.ownerAddress!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (pet.ownerAddress != null) const SizedBox(height: 2),
                    if (pet.likedAt != null)
                      Text(
                        '간식 준 날: ${_formatDate(pet.likedAt!)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage(Pet pet) {
    // 유효한 이미지 URL만 필터링
    List<String> validImages =
        pet.profileImages
            .where((url) => url.trim().isNotEmpty)
            .where((url) => !url.startsWith('file://'))
            .where(
              (url) => url.startsWith('http://') || url.startsWith('https://'),
            )
            .where((url) => Uri.tryParse(url) != null)
            .toList();

    if (validImages.isNotEmpty) {
      String imageUrl = validImages.first;

      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage(pet.species);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            );
          },
        ),
      );
    }

    // 유효한 이미지가 없으면 플레이스홀더 표시
    return _buildPlaceholderImage(pet.species);
  }

  Widget _buildPlaceholderImage(String species) {
    IconData icon = species == '강아지' ? Icons.pets : Icons.favorite;
    return Center(child: Icon(icon, size: 40, color: Colors.grey[400]));
  }

  String _formatDate(DateTime date) {
    var now = DateTime.now();
    var difference = now.difference(date);

    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      var weeks = (difference.inDays / 7).floor();
      return '$weeks주 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
