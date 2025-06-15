import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';

class PetService {
  static Future<List<Pet>> getAllPets() async {
    try {
      var response = await SupabaseService.client
          .from('pets')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return response.map<Pet>((petData) => Pet.fromJson(petData)).toList();
    } catch (error) {
      throw Exception('펫 목록 조회 실패: $error');
    }
  }

  static Future<List<Pet>> getPetsByUser(String userId) async {
    try {
      var response = await SupabaseService.client
          .from('pets')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      return response.map<Pet>((petData) => Pet.fromJson(petData)).toList();
    } catch (error) {
      throw Exception('사용자 펫 목록 조회 실패: $error');
    }
  }

  static Future<Pet> createPet(Pet pet) async {
    try {
      var userId = AuthService.getCurrentUserId();
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      var petWithOwner = pet.copyWith(ownerId: userId);
      var petData = petWithOwner.toJson();

      // 필수 필드 검증
      if (petData['name'] == null ||
          petData['name'].toString().trim().isEmpty) {
        throw Exception('반려동물 이름을 입력해주세요');
      }

      if (petData['species'] == null ||
          petData['species'].toString().trim().isEmpty) {
        throw Exception('동물 종류를 선택해주세요');
      }

      if (petData['breed'] == null ||
          petData['breed'].toString().trim().isEmpty) {
        throw Exception('품종을 선택해주세요');
      }

      if (petData['gender'] == null ||
          petData['gender'].toString().trim().isEmpty) {
        throw Exception('성별을 선택해주세요');
      }

      var age = petData['age'];
      if (age == null || (age is int && age < 1)) {
        throw Exception('올바른 나이를 입력해주세요');
      }

      // 성별이 허용된 값인지 확인
      if (!['수컷', '암컷'].contains(petData['gender'])) {
        throw Exception('성별은 "수컷" 또는 "암컷"만 허용됩니다');
      }

      // 성격 배열이 비어있지 않은지 확인
      var personality = petData['personality'];
      if (personality == null || (personality is List && personality.isEmpty)) {
        throw Exception('성격을 최소 1개 이상 선택해주세요');
      }

      // 중성화 상태가 있는 경우 허용된 값인지 확인
      if (petData['is_neutered'] != null &&
          !['완료', '안함', '모름'].contains(petData['is_neutered'])) {
        throw Exception('중성화 상태는 "완료", "안함", "모름" 중 하나여야 합니다');
      }

      // 백신 상태가 있는 경우 허용된 값인지 확인
      if (petData['vaccination_status'] != null &&
          !['완료', '미완료', '진행중', '모름'].contains(petData['vaccination_status'])) {
        throw Exception('백신 상태는 "완료", "미완료", "진행중", "모름" 중 하나여야 합니다');
      }

      var response =
          await SupabaseService.client
              .from('pets')
              .insert(petData)
              .select()
              .single();

      return Pet.fromJson(response);
    } catch (error) {
      if (error.toString().contains(
        'duplicate key value violates unique constraint',
      )) {
        throw Exception('이미 등록된 반려동물입니다');
      } else if (error.toString().contains('violates foreign key constraint')) {
        throw Exception('유효하지 않은 사용자입니다. 다시 로그인해주세요');
      } else if (error.toString().contains('violates check constraint')) {
        if (error.toString().contains('pets_gender_check')) {
          throw Exception('성별은 "수컷" 또는 "암컷"만 입력 가능합니다');
        } else if (error.toString().contains('pets_vaccination_status_check')) {
          throw Exception('백신 상태는 "완료", "미완료", "진행중", "모름" 중 하나만 입력 가능합니다');
        } else {
          throw Exception('입력된 데이터가 유효하지 않습니다');
        }
      } else if (error.toString().contains('permission denied')) {
        throw Exception('반려동물 등록 권한이 없습니다');
      } else {
        throw Exception('펫 등록 실패: $error');
      }
    }
  }

  static Future<Pet> updatePet(Pet pet) async {
    try {
      if (pet.id == null) {
        throw Exception('펫 ID가 없습니다');
      }

      // 업데이트용 데이터 준비 (id와 owner_id 제외)
      var updateData = pet.toJson();
      updateData.remove('id'); // ID는 WHERE 조건에서 사용
      updateData.remove('owner_id'); // 소유자는 변경하지 않음

      var response =
          await SupabaseService.client
              .from('pets')
              .update(updateData)
              .eq('id', pet.id!)
              .eq('owner_id', pet.ownerId) // 소유자 확인
              .select()
              .single();

      return Pet.fromJson(response);
    } catch (error) {
      if (error.toString().contains('violates check constraint')) {
        if (error.toString().contains('pets_gender_check')) {
          throw Exception('성별은 "수컷" 또는 "암컷"만 입력 가능합니다');
        } else if (error.toString().contains('pets_vaccination_status_check')) {
          throw Exception('예방접종 상태는 "완료", "미완료", "진행중", "모름" 중 하나만 입력 가능합니다');
        } else if (error.toString().contains('pets_is_neutered_check')) {
          throw Exception('중성화 여부는 "완료", "안함", "모름" 중 하나만 입력 가능합니다');
        } else {
          throw Exception('입력된 데이터가 유효하지 않습니다: $error');
        }
      } else if (error.toString().contains('permission denied')) {
        throw Exception('펫 정보 수정 권한이 없습니다');
      } else if (error.toString().contains('No rows found')) {
        throw Exception('수정할 펫을 찾을 수 없거나 권한이 없습니다');
      } else {
        throw Exception('펫 정보 수정 실패: $error');
      }
    }
  }

  static Future<void> deletePet(int petId) async {
    try {
      var currentUserId = AuthService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('로그인이 필요합니다');
      }

      await SupabaseService.client
          .from('pets')
          .delete()
          .eq('id', petId)
          .eq('owner_id', currentUserId);
    } catch (error) {
      throw Exception('펫 삭제 실패: $error');
    }
  }

  static Future<List<Pet>> getLikedPets([String? userId]) async {
    try {
      var currentUserId = userId ?? AuthService.getCurrentUserId();
      if (currentUserId == null) {
        return [];
      }

      var response = await SupabaseService.client
          .from('pet_likes')
          .select('''
            created_at,
            pets!inner(
              id, owner_id, name, species, breed, age, gender,
              neutering_status, vaccination_status, personality,
              profile_images, description, is_available,
              created_at, updated_at, activity_level, size, weight, is_neutered
            )
          ''')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      List<Pet> likedPets = [];

      for (var item in response) {
        try {
          var petData = item['pets'] as Map<String, dynamic>;
          var likedAt = item['created_at'] as String;

          var ownerId = petData['owner_id'] as String;
          var userResponse =
              await SupabaseService.client
                  .from('users')
                  .select('name, profile_image_url')
                  .eq('id', ownerId)
                  .maybeSingle();

          var locationResponse =
              await SupabaseService.client
                  .from('locations')
                  .select('address, city, district')
                  .eq('user_id', ownerId)
                  .eq('category', 'user_address')
                  .eq('is_default', true)
                  .eq('is_active', true)
                  .maybeSingle();

          var pet = Pet.fromJson({
            ...petData,
            'owner_name': userResponse?['name'],
            'owner_profile_image': userResponse?['profile_image_url'],
            'owner_address': locationResponse?['address'],
            'owner_city': locationResponse?['city'],
            'owner_district': locationResponse?['district'],
            'liked_at': likedAt,
          });

          likedPets.add(pet);
        } catch (e) {
          continue;
        }
      }

      return likedPets;
    } catch (error) {
      throw Exception('좋아요한 펫 목록 조회 실패: $error');
    }
  }

  static Future<bool> likePet(String userId, int petId) async {
    try {
      var existing = await SupabaseService.client
          .from('pet_likes')
          .select()
          .eq('user_id', userId)
          .eq('pet_id', petId);

      if (existing.isNotEmpty) {
        return false;
      }

      await SupabaseService.client.from('pet_likes').insert({
        'user_id': userId,
        'pet_id': petId,
      });

      return true;
    } catch (error) {
      if (error.toString().contains('unique_user_pet_like') ||
          error.toString().contains('duplicate key')) {
        return false;
      }
      throw Exception('펫 좋아요 실패: $error');
    }
  }

  static Future<bool> unlikePet(String userId, int petId) async {
    try {
      await SupabaseService.client
          .from('pet_likes')
          .delete()
          .eq('user_id', userId)
          .eq('pet_id', petId);

      return true;
    } catch (error) {
      throw Exception('펫 좋아요 취소 실패: $error');
    }
  }

  static Future<bool> rejectPet(String userId, int petId) async {
    try {
      var existing = await SupabaseService.client
          .from('pet_rejections')
          .select()
          .eq('user_id', userId)
          .eq('pet_id', petId);

      if (existing.isNotEmpty) {
        return false;
      }

      await SupabaseService.client.from('pet_rejections').insert({
        'user_id': userId,
        'pet_id': petId,
      });

      return true;
    } catch (error) {
      if (error.toString().contains('unique_user_pet_rejection') ||
          error.toString().contains('duplicate key')) {
        return false;
      }
      throw Exception('펫 거절 실패: $error');
    }
  }

  static Future<bool> unrejectPet(String userId, int petId) async {
    try {
      await SupabaseService.client
          .from('pet_rejections')
          .delete()
          .eq('user_id', userId)
          .eq('pet_id', petId);

      return true;
    } catch (error) {
      throw Exception('펫 거절 취소 실패: $error');
    }
  }

  static Future<bool> isPetRejected(String userId, int petId) async {
    try {
      var response = await SupabaseService.client
          .from('pet_rejections')
          .select()
          .eq('user_id', userId)
          .eq('pet_id', petId);

      return response.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  // 성격 옵션들
  static const List<String> personalityOptions = [
    '활발한',
    '온순한',
    '친근한',
    '독립적인',
    '장난스러운',
    '조용한',
    '사교적인',
    '경계심많은',
    '애교많은',
    '똑똑한',
    '호기심많은',
    '차분한',
    '용감한',
    '겁많은',
    '고집센',
    '순종적인',
    '에너지넘치는',
    '게으른',
  ];

  // 견종 옵션들
  static const Map<String, List<String>> breedOptions = {
    '강아지': [
      '골든 리트리버',
      '래브라도 리트리버',
      '시바견',
      '진돗개',
      '푸들',
      '말티즈',
      '포메라니안',
      '치와와',
      '요크셔테리어',
      '불독',
      '보더콜리',
      '허스키',
      '코기',
      '비글',
      '닥스훈트',
      '믹스견',
      '기타',
    ],
    '고양이': [
      '러시안블루',
      '페르시안',
      '스코티시폴드',
      '브리티시숏헤어',
      '메인쿤',
      '랙돌',
      '벵갈',
      '샴',
      '터키쉬앙고라',
      '노르웨이숲',
      '아메리칸숏헤어',
      '싱가푸라',
      '코리안숏헤어',
      '믹스묘',
      '기타',
    ],
  };

  // 성별 옵션들 (모름 제거)
  static const List<String> genderOptions = ['수컷', '암컷'];

  // 크기 옵션들
  static const List<String> sizeOptions = [
    '소형 (7kg 미만)',
    '중형 (7-25kg)',
    '대형 (25kg 이상)',
  ];

  // 활동량 옵션들
  static const List<String> activityLevelOptions = ['낮음', '보통', '높음'];

  // 중성화 상태 옵션들
  static const List<String> neuteringStatusOptions = ['완료', '안함', '모름'];

  // 예방접종 상태 옵션들
  static const List<String> vaccinationStatusOptions = [
    '완료',
    '미완료',
    '진행중',
    '모름',
  ];

  // 현재 사용자의 위치 기반으로 5km 반경 내 펫들 조회 (유저 위치 기반)
  static Future<List<Pet>> getPetsNearby({double radiusKm = 5.0}) async {
    try {
      var currentUserId = AuthService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('로그인이 필요합니다');
      }

      var response = await SupabaseService.client.rpc(
        'get_pets_near_user',
        params: {'target_user_id': currentUserId, 'radius_km': radiusKm},
      );

      if (response == null) {
        return await _getFallbackPets(currentUserId, radiusKm);
      }

      var responseList = response as List<dynamic>;
      if (responseList.isEmpty) {
        return await _getFallbackPets(currentUserId, radiusKm);
      }

      List<Pet> pets = [];
      for (var data in responseList) {
        try {
          var petData = data as Map<String, dynamic>;
          var pet = Pet.fromJson(petData);
          pets.add(pet);
        } catch (_) {
          continue;
        }
      }

      return pets;
    } on PostgrestException {
      return await _getFallbackPets(AuthService.getCurrentUserId()!, radiusKm);
    } catch (_) {
      return await _getFallbackPets(AuthService.getCurrentUserId()!, radiusKm);
    }
  }

  // 현재 사용자의 위치 기반으로 5km 반경 내 펫들 조회 (좋아요, 거절 포함)
  static Future<List<Pet>> getPetsNearbyWithAll({double radiusKm = 5.0}) async {
    try {
      var currentUserId = AuthService.getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 1. 내 펫을 제외한 모든 펫 조회
      var petsResponse = await SupabaseService.client
          .from('pets')
          .select()
          .eq('is_available', true)
          .neq('owner_id', currentUserId) // 내 펫 제외
          .order('created_at', ascending: false);

      List<Pet> pets = [];

      for (var petData in petsResponse) {
        try {
          var ownerId = petData['owner_id'] as String;

          // 2. 각 펫 소유자의 위치 조회 (강화된 로직)

          List<dynamic> allLocationsResponse = [];

          try {
            // 모든 위치 정보를 조회
            allLocationsResponse = await SupabaseService.client
                .from('locations')
                .select('*')
                .eq('user_id', ownerId)
                .eq('category', 'user_address');
          } catch (e) {
            // Handle error silently
          }

          Map<String, dynamic>? locationResponse;

          if (allLocationsResponse.isNotEmpty) {
            // 1순위: 기본주소이면서 활성화된 것
            for (var location in allLocationsResponse) {
              var locationMap = location as Map<String, dynamic>;
              if (locationMap['is_default'] == true &&
                  locationMap['is_active'] == true) {
                locationResponse = locationMap;
                break;
              }
            }

            // 2순위: 기본주소 (활성화 상태 무관)
            if (locationResponse == null) {
              for (var location in allLocationsResponse) {
                var locationMap = location as Map<String, dynamic>;
                if (locationMap['is_default'] == true) {
                  locationResponse = locationMap;
                  break;
                }
              }
            }

            // 3순위: 활성화된 아무 위치
            if (locationResponse == null) {
              for (var location in allLocationsResponse) {
                var locationMap = location as Map<String, dynamic>;
                if (locationMap['is_active'] == true) {
                  locationResponse = locationMap;
                  break;
                }
              }
            }

            // 4순위: 아무 위치나 (최후의 수단)
            locationResponse ??=
                allLocationsResponse.first as Map<String, dynamic>;
          }

          double latitude, longitude;
          if (locationResponse != null) {
            try {
              // 문자열로 저장된 경우를 대비해 파싱
              var latStr = locationResponse['latitude'].toString();
              var lngStr = locationResponse['longitude'].toString();
              latitude = double.parse(latStr);
              longitude = double.parse(lngStr);
            } catch (e) {
              // 파싱 실패시 해당 펫 건너뛰기
              continue;
            }
          } else {
            // 위치 정보가 없으면 해당 펫 건너뛰기
            continue;
          }

          // 3. 소유자 정보 조회
          var userResponse =
              await SupabaseService.client
                  .from('users')
                  .select('name, profile_image_url')
                  .eq('id', ownerId)
                  .maybeSingle();

          var pet = Pet.fromJson({
            ...petData,
            'latitude': latitude,
            'longitude': longitude,
            'distance_km': 0.0,
            'owner_name': userResponse?['name'],
            'owner_profile_image': userResponse?['profile_image_url'],
            'owner_address': locationResponse['address'],
            'owner_city': locationResponse['city'],
            'owner_district': locationResponse['district'],
          });

          pets.add(pet);
        } catch (e) {
          continue;
        }
      }

      return pets;
    } catch (e) {
      throw Exception('펫 조회 실패: $e');
    }
  }

  static Future<List<Pet>> _getFallbackPets(
    String currentUserId,
    double radiusKm,
  ) async {
    var userLocationResponse =
        await SupabaseService.client
            .from('locations')
            .select('latitude, longitude')
            .eq('user_id', currentUserId)
            .eq('category', 'user_address')
            .eq('is_default', true)
            .eq('is_active', true)
            .maybeSingle();

    userLocationResponse ??=
        await SupabaseService.client
            .from('locations')
            .select('latitude, longitude')
            .eq('user_id', currentUserId)
            .eq('category', 'user_address')
            .eq('is_active', true)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

    if (userLocationResponse == null) {
      var response = await SupabaseService.client
          .from('pets')
          .select()
          .eq('is_available', true)
          .neq('owner_id', currentUserId)
          .order('created_at', ascending: false);

      return response.map<Pet>((petData) => Pet.fromJson(petData)).toList();
    }

    var userLat = (userLocationResponse['latitude'] as num).toDouble();
    var userLng = (userLocationResponse['longitude'] as num).toDouble();

    var petsResponse = await SupabaseService.client
        .from('pets')
        .select('*')
        .eq('is_available', true)
        .neq('owner_id', currentUserId)
        .order('created_at', ascending: false);

    List<Pet> nearbyPets = [];

    for (var petData in petsResponse) {
      try {
        var ownerId = petData['owner_id'] as String;

        var userResponse =
            await SupabaseService.client
                .from('users')
                .select('id, name, profile_image_url')
                .eq('id', ownerId)
                .maybeSingle();

        if (userResponse == null) continue;

        var locationResponse =
            await SupabaseService.client
                .from('locations')
                .select('latitude, longitude, address, city, district')
                .eq('user_id', ownerId)
                .eq('category', 'user_address')
                .eq('is_default', true)
                .eq('is_active', true)
                .maybeSingle();

        locationResponse ??=
            await SupabaseService.client
                .from('locations')
                .select('latitude, longitude, address, city, district')
                .eq('user_id', ownerId)
                .eq('category', 'user_address')
                .eq('is_active', true)
                .order('created_at', ascending: false)
                .limit(1)
                .maybeSingle();

        if (locationResponse == null) continue;

        var petLat = (locationResponse['latitude'] as num).toDouble();
        var petLng = (locationResponse['longitude'] as num).toDouble();

        var distance = _calculateDistance(userLat, userLng, petLat, petLng);

        if (distance <= radiusKm) {
          var pet = Pet.fromJson({
            ...petData,
            'owner_name': userResponse['name'] as String?,
            'owner_profile_image': userResponse['profile_image_url'] as String?,
            'owner_address': locationResponse['address'] as String?,
            'owner_city': locationResponse['city'] as String?,
            'owner_district': locationResponse['district'] as String?,
            'distance_km': distance,
          });
          nearbyPets.add(pet);
        }
      } catch (e) {
        continue;
      }
    }

    nearbyPets.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

    var nearbyPetsFiltered = <Pet>[];
    for (var pet in nearbyPets) {
      try {
        var likedCheck =
            await SupabaseService.client
                .from('pet_likes')
                .select('id')
                .eq('user_id', currentUserId)
                .eq('pet_id', pet.id!)
                .maybeSingle();

        var rejectedCheck =
            await SupabaseService.client
                .from('pet_rejections')
                .select('id')
                .eq('user_id', currentUserId)
                .eq('pet_id', pet.id!)
                .maybeSingle();

        if (likedCheck == null && rejectedCheck == null) {
          nearbyPetsFiltered.add(pet);
        }
      } catch (_) {
        nearbyPetsFiltered.add(pet);
      }
    }

    return nearbyPetsFiltered;
  }

  // 거리 계산 함수 (하버사인 공식)
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;

    double dLat = _radians(lat2 - lat1);
    double dLon = _radians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_radians(lat1)) *
            cos(_radians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  static double _radians(double degrees) {
    return degrees * pi / 180;
  }
}
