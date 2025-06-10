import 'dart:math';
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

      var response =
          await SupabaseService.client
              .from('pets')
              .update(pet.toJson())
              .eq('id', pet.id!)
              .select()
              .single();

      return Pet.fromJson(response);
    } catch (error) {
      throw Exception('펫 정보 수정 실패: $error');
    }
  }

  static Future<void> deletePet(int petId) async {
    try {
      await SupabaseService.client.from('pets').delete().eq('id', petId);
    } catch (error) {
      throw Exception('펫 삭제 실패: $error');
    }
  }

  static Future<List<Pet>> getLikedPets(String userId) async {
    try {
      var response = await SupabaseService.client
          .from('pet_likes')
          .select('''
            pet_id,
            pets (*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .where((item) => item['pets'] != null)
          .map<Pet>((item) => Pet.fromJson(item['pets']))
          .toList();
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
        return true;
      }

      await SupabaseService.client.from('pet_likes').insert({
        'user_id': userId,
        'pet_id': petId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (error) {
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

  static Future<bool> isPetLiked(String userId, int petId) async {
    try {
      var response = await SupabaseService.client
          .from('pet_likes')
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

      // 새로운 UUID 기반 RPC 함수 사용
      var response = await SupabaseService.client.rpc(
        'get_pets_near_user',
        params: {'target_user_id': currentUserId, 'radius_km': radiusKm},
      );

      if (response == null || (response is List && response.isEmpty)) {
        return await _fallbackLocationSearch(currentUserId, radiusKm);
      }

      var pets =
          (response as List).map<Pet>((petData) {
            var data = petData as Map<String, dynamic>;
            // UUID 기반 데이터 매핑
            return Pet.fromJson({
              'id': data['id'],
              'owner_id': data['owner_id'],
              'name': data['name'],
              'species': data['species'],
              'breed': data['breed'],
              'age': data['age'],
              'gender': data['gender'],
              'neutering_status': data['neutering_status'],
              'vaccination_status': data['vaccination_status'],
              'personality':
                  data['personality'] is String
                      ? [data['personality']]
                      : data['personality'] ?? [],
              'profile_images':
                  data['profile_images'] is String
                      ? [data['profile_images']]
                      : data['profile_images'] ?? [],
              'description': data['description'],
              'is_available': data['is_available'],
              'created_at': data['created_at'],
              'updated_at': data['updated_at'],
              'activity_level': data['activity_level'],
              'size': data['size'],
              'weight': data['weight'],
              'is_neutered': data['is_neutered'],
              'distance_km': data['distance_km'],
              'owner_name': data['owner_name'],
              'owner_address': data['owner_location'],
            });
          }).toList();

      // 거리 순으로 정렬
      pets.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

      return pets;
    } catch (error) {
      // RPC 함수 사용 실패 시 폴백 검색 수행
      try {
        var currentUserId = AuthService.getCurrentUserId();
        if (currentUserId == null) {
          return [];
        }
        return await _fallbackLocationSearch(currentUserId, radiusKm);
      } catch (fallbackError) {
        throw Exception('주변 펫 목록 조회 실패: $fallbackError');
      }
    }
  }

  // 폴백 위치 기반 검색 함수
  static Future<List<Pet>> _fallbackLocationSearch(
    String currentUserId,
    double radiusKm,
  ) async {
    // 1. 현재 사용자의 위치 조회
    var userLocationResponse =
        await SupabaseService.client
            .from('locations')
            .select('latitude, longitude')
            .eq('user_id', currentUserId)
            .eq('category', 'user_address')
            .eq('is_default', true)
            .eq('is_active', true)
            .maybeSingle();

    // 기본 주소가 없으면 가장 최근 주소 사용
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
      // 위치 정보가 없으면 모든 펫 반환 (자신 제외)
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

    // 2. 다른 사용자들의 위치 정보와 펫 정보 조회 (foreign key 없이 수동 조인)
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

        // 펫 소유자 정보 조회
        var userResponse =
            await SupabaseService.client
                .from('users')
                .select('id, name, profile_image_url')
                .eq('id', ownerId)
                .maybeSingle();

        if (userResponse == null) continue;

        // 펫 소유자의 기본 주소 조회
        var locationResponse =
            await SupabaseService.client
                .from('locations')
                .select('latitude, longitude, address, city, district')
                .eq('user_id', ownerId)
                .eq('category', 'user_address')
                .eq('is_default', true)
                .eq('is_active', true)
                .maybeSingle();

        // 기본 주소가 없으면 가장 최근 주소 사용
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

        // 거리 계산
        var distance = _calculateDistance(userLat, userLng, petLat, petLng);

        if (distance <= radiusKm) {
          // Pet 객체에 owner 정보와 거리 정보 추가
          var pet = Pet.fromJson({
            ...petData,
            'owner_name': userResponse['name'],
            'owner_profile_image': userResponse['profile_image_url'],
            'owner_address': locationResponse['address'],
            'owner_city': locationResponse['city'],
            'owner_district': locationResponse['district'],
            'distance_km': distance,
          });
          nearbyPets.add(pet);
        }
      } catch (e) {
        continue;
      }
    }

    // 거리순으로 정렬
    nearbyPets.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

    return nearbyPets;
  }

  // 거리 계산 함수 (하버사인 공식)
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // 지구 반지름 (km)

    var dLat = _degreesToRadians(lat2 - lat1);
    var dLon = _degreesToRadians(lon2 - lon1);

    var a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
