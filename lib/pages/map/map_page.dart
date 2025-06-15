import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/pages/chat/chat_detail_page.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/chat_service.dart';
import 'package:udangtan_flutter_app/services/pet_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
    required this.currentNavIndex,
    required this.onNavTap,
  });

  final int currentNavIndex;
  final Function(int) onNavTap;

  @override
  State<MapPage> createState() => _MapPageState();
}

class UserData {
  UserData({
    required this.userId,
    required this.name,
    required this.gender,
    required this.age,
    required this.profileImageUrl,
    required this.profileMessage,
  });
  final String userId;
  final String name;
  final String gender;
  final int age;
  final String profileImageUrl;
  final String profileMessage;
}

class PetGroup {
  PetGroup({
    required this.latitude,
    required this.longitude,
    required this.pets,
  });
  final double latitude;
  final double longitude;
  final List<Pet> pets;
}

class _MapPageState extends State<MapPage> {
  List<CustomOverlay> customOverlays = [];
  KakaoMapController? mapController;
  LatLng mapCenter = LatLng(37.49877286215097, 126.95220910952861);
  List<Pet> _allPets = [];
  List<PetGroup> _petGroups = [];

  static const String markerImageUrl =
      'https://velog.velcdn.com/images/vewevteen/post/40b5e857-5c31-4717-8955-8cfb6cb57918/image.png';

  Future<void> _initializePets() async {
    try {
      var allPets = await PetService.getPetsNearbyWithAll(radiusKm: 5.0);
      var currentUserId = AuthService.getCurrentUserId();

      _allPets =
          allPets.where((pet) {
            var isMyPet = pet.ownerId == currentUserId;
            return !isMyPet;
          }).toList();

      if (_allPets.isNotEmpty) {
        _groupPetsByLocation();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _groupPetsByLocation() {
    Map<String, List<Pet>> locationGroups = {};

    for (var pet in _allPets) {
      if (pet.latitude != null && pet.longitude != null) {
        String locationKey =
            '${pet.latitude!.toStringAsFixed(6)}_${pet.longitude!.toStringAsFixed(6)}';

        if (locationGroups[locationKey] == null) {
          locationGroups[locationKey] = [];
        }
        locationGroups[locationKey]!.add(pet);
      }
    }

    _petGroups =
        locationGroups.entries.map((entry) {
          var pets = entry.value;
          return PetGroup(
            latitude: pets.first.latitude!,
            longitude: pets.first.longitude!,
            pets: pets,
          );
        }).toList();

    if (_petGroups.isNotEmpty) {
      mapCenter = LatLng(_petGroups.first.latitude, _petGroups.first.longitude);
    }
  }

  void _showPetListModal(List<Pet> pets, LatLng location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[100]!, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '이 위치의 반려동물',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '총 ${pets.length}마리',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      var pet = pets[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pop(context);
                              _showPetDetailModal(pet);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          pet.profileImages.isNotEmpty
                                              ? NetworkImage(
                                                pet.profileImages.first,
                                              )
                                              : null,
                                      backgroundColor: Colors.grey[200],
                                      child:
                                          pet.profileImages.isEmpty
                                              ? Text(
                                                pet.name.substring(0, 1),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              )
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pet.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                pet.species,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${pet.breed} • ${pet.age}살',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (pet.description?.isNotEmpty ==
                                            true) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            pet.description!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[500],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _showPetDetailModal(pet);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: AppColors.primary,
                                            elevation: 0,
                                            side: const BorderSide(
                                              color: AppColors.primary,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            '상세보기',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: 80,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _openChatWithPet(pet);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            '채팅하기',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showPetDetailModal(Pet pet) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.8),
                          AppColors.primary.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              image:
                                  pet.profileImages.isNotEmpty
                                      ? DecorationImage(
                                        image: NetworkImage(
                                          pet.profileImages.first,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      pet.species,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${pet.breed} • ${pet.age}살 • ${pet.gender}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pet.description?.isNotEmpty == true) ...[
                            const Text(
                              '소개',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Text(
                                pet.description!,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _openChatWithPet(pet);
                              },
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('채팅하기'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _openChatWithPet(Pet pet) async {
    try {
      var currentUserId = AuthService.getCurrentUserId();
      if (currentUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
        }
        return;
      }

      if (pet.ownerId == currentUserId) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('자신의 반려동물과는 채팅할 수 없습니다')),
          );
        }
        return;
      }

      var chatRoom = await ChatService.findOrCreatePetChatRoom(
        currentUserId: currentUserId,
        targetPetId: pet.id!,
      );

      if (mounted && chatRoom != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(chatRoom: chatRoom),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('채팅방 생성 실패: $e')));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializePets();
  }

  @override
  Widget build(BuildContext context) {
    var markers =
        _petGroups.map((group) {
          return Marker(
            markerId: 'group_${group.latitude}_${group.longitude}',
            latLng: LatLng(group.latitude, group.longitude),
            markerImageSrc: markerImageUrl,
            height: 32,
          );
        }).toList();

    var petCountOverlays =
        _petGroups.where((group) => group.pets.length > 1).map((group) {
          return CustomOverlay(
            customOverlayId: 'count_${group.latitude}_${group.longitude}',
            latLng: LatLng(group.latitude, group.longitude),
            content:
                '<div style="background-color: #FF6B6B; color: white; border-radius: 50%; width: 20px; height: 20px; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: bold; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3); font-family: Arial, sans-serif;">${group.pets.length}</div>',
            xAnchor: 0.6,
            yAnchor: 0.3,
            zIndex: 5,
          );
        }).toList();

    List<CustomOverlay> allOverlays = [...customOverlays, ...petCountOverlays];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: const CommonAppBar(
          title: '내 주변',
          automaticallyImplyLeading: false,
        ),
        body: KakaoMap(
          onMapCreated: (controller) async {
            mapController = controller;
          },
          onMarkerTap: (markerId, latLng, zoomLevel) async {
            if (mapController != null) {
              await mapController!.setCenter(latLng);
            }

            PetGroup? targetGroup;
            for (var group in _petGroups) {
              if ((group.latitude - latLng.latitude).abs() < 0.000001 &&
                  (group.longitude - latLng.longitude).abs() < 0.000001) {
                targetGroup = group;
                break;
              }
            }

            if (targetGroup != null) {
              setState(() {
                customOverlays.clear();
              });

              if (targetGroup.pets.length == 1) {
                _showPetDetailModal(targetGroup.pets.first);
              } else {
                _showPetListModal(targetGroup.pets, latLng);
              }
            }
          },
          onMapTap: (latLng) {
            setState(() {
              customOverlays.clear();
            });
          },
          customOverlays: allOverlays,
          markers: markers,
          center: mapCenter,
        ),
      ),
    );
  }
}
