import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:udangtan_flutter_app/app/env_config.dart';
import 'package:udangtan_flutter_app/models/user_location.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';

class LocationService {
  static final String _kakaoApiKey = EnvConfig.kakaoRestApiKey;
  static const String _addressSearchUrl =
      'https://dapi.kakao.com/v2/local/search/address.json';
  static const String _placeSearchUrl =
      'https://dapi.kakao.com/v2/local/search/keyword.json';

  // 카카오 주소 검색
  static Future<List<KakaoAddressResult>> searchAddress(String query) async {
    try {
      var response = await http.get(
        Uri.parse('$_addressSearchUrl?query=$query'),
        headers: {'Authorization': 'KakaoAK $_kakaoApiKey'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body) as Map<String, dynamic>;
        List<KakaoAddressResult> results = [];

        for (var item in data['documents'] as List) {
          results.add(
            KakaoAddressResult.fromJson(item as Map<String, dynamic>),
          );
        }

        return results;
      } else {
        throw Exception('주소 검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('주소 검색 오류: $e');
    }
  }

  // 카카오 장소 검색
  static Future<List<KakaoPlaceResult>> searchPlace(String query) async {
    try {
      var response = await http.get(
        Uri.parse('$_placeSearchUrl?query=$query'),
        headers: {'Authorization': 'KakaoAK $_kakaoApiKey'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body) as Map<String, dynamic>;
        List<KakaoPlaceResult> results = [];

        for (var item in data['documents'] as List) {
          results.add(KakaoPlaceResult.fromJson(item as Map<String, dynamic>));
        }

        return results;
      } else {
        throw Exception('장소 검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('장소 검색 오류: $e');
    }
  }

  // 사용자 주소 목록 조회
  static Future<List<UserLocation>> getUserAddresses(String userId) async {
    try {
      var response = await SupabaseService.client
          .from('locations')
          .select()
          .eq('user_id', userId)
          .eq('category', 'user_address')
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      List<UserLocation> addresses = [];
      for (var item in response) {
        addresses.add(UserLocation.fromSupabase(item));
      }

      return addresses;
    } catch (e) {
      throw Exception('주소 목록 조회 실패: $e');
    }
  }

  // 기본 주소 조회
  static Future<UserLocation?> getDefaultAddress(String userId) async {
    try {
      var response =
          await SupabaseService.client
              .from('locations')
              .select()
              .eq('user_id', userId)
              .eq('category', 'user_address')
              .eq('is_default', true)
              .maybeSingle();

      if (response != null) {
        return UserLocation.fromSupabase(response);
      }

      var fallbackResponse =
          await SupabaseService.client
              .from('locations')
              .select()
              .eq('user_id', userId)
              .eq('category', 'user_address')
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

      if (fallbackResponse != null) {
        return UserLocation.fromSupabase(fallbackResponse);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // 주소 추가
  static Future<UserLocation> addAddress(UserLocation address) async {
    try {
      if (address.isDefault && address.userId != null) {
        await SupabaseService.client
            .from('locations')
            .update({'is_default': false})
            .eq('user_id', address.userId!)
            .eq('category', 'user_address');
      }

      var data = address.toSupabaseInsert();
      var response =
          await SupabaseService.client
              .from('locations')
              .insert(data)
              .select()
              .single();

      return UserLocation.fromSupabase(response);
    } catch (e) {
      throw Exception('주소 저장 실패: $e');
    }
  }

  // 주소 수정
  static Future<UserLocation> updateAddress(UserLocation address) async {
    try {
      if (address.isDefault && address.userId != null) {
        await SupabaseService.client
            .from('locations')
            .update({'is_default': false})
            .eq('user_id', address.userId!)
            .eq('category', 'user_address')
            .neq('id', address.id);
      }

      var data = address.toSupabaseUpdate();
      var response =
          await SupabaseService.client
              .from('locations')
              .update(data)
              .eq('id', address.id)
              .select()
              .single();

      return UserLocation.fromSupabase(response);
    } catch (e) {
      throw Exception('주소 수정 실패: $e');
    }
  }

  // 주소 삭제
  static Future<void> deleteAddress(int addressId) async {
    try {
      await SupabaseService.client
          .from('locations')
          .delete()
          .eq('id', addressId);
    } catch (e) {
      throw Exception('주소 삭제 실패: $e');
    }
  }

  // 기본 주소 설정
  static Future<void> setDefaultAddress(int addressId, String userId) async {
    try {
      await SupabaseService.client
          .from('locations')
          .update({'is_default': false})
          .eq('user_id', userId)
          .eq('category', 'user_address');

      await SupabaseService.client
          .from('locations')
          .update({'is_default': true})
          .eq('id', addressId);
    } catch (e) {
      throw Exception('기본 주소 설정 실패: $e');
    }
  }

  // 카카오 주소 검색 결과를 UserLocation으로 변환
  static UserLocation createUserLocationFromKakao({
    required String userId,
    required String addressName,
    required KakaoAddressResult kakaoResult,
    String? detailAddress,
    bool isDefault = false,
  }) {
    var addressParts = kakaoResult.address.split(' ');
    var city = addressParts.isNotEmpty ? addressParts[0] : '';
    var district = addressParts.length > 1 ? addressParts[1] : '';

    return UserLocation(
      id: 0,
      userId: userId,
      name: addressName,
      category: 'user_address',
      address: kakaoResult.address,
      city: city,
      district: district,
      roadAddress: kakaoResult.roadAddress,
      jibunAddress: kakaoResult.address,
      buildingName: kakaoResult.buildingName,
      detailAddress: detailAddress,
      latitude: kakaoResult.latitude,
      longitude: kakaoResult.longitude,
      isDefault: isDefault,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 카카오 장소 검색 결과를 UserLocation으로 변환
  static UserLocation createUserLocationFromPlace({
    required String userId,
    required String addressName,
    required KakaoPlaceResult placeResult,
    String? detailAddress,
    bool isDefault = false,
  }) {
    var addressParts = placeResult.address.split(' ');
    var city = addressParts.isNotEmpty ? addressParts[0] : '';
    var district = addressParts.length > 1 ? addressParts[1] : '';

    return UserLocation(
      id: 0,
      userId: userId,
      name: addressName,
      category: 'user_address',
      address: placeResult.address,
      city: city,
      district: district,
      roadAddress: placeResult.roadAddress,
      jibunAddress: placeResult.address,
      buildingName: placeResult.placeName,
      detailAddress: detailAddress,
      latitude: placeResult.latitude,
      longitude: placeResult.longitude,
      isDefault: isDefault,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 주변 장소 검색 (공공 장소)
  static Future<List<UserLocation>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    List<String>? categories,
  }) async {
    try {
      var query = SupabaseService.client
          .from('locations')
          .select('*')
          .neq('category', 'user_address')
          .eq('is_active', true);

      if (categories != null && categories.isNotEmpty) {
        // categories 조건을 OR로 처리
        var categoryFilter = categories
            .map((cat) => 'category.eq.$cat')
            .join(',');
        query = query.or(categoryFilter);
      }

      var response = await query;

      var locations =
          (response as List)
              .map((json) => UserLocation.fromJson(json))
              .toList();

      // 거리 기준 필터링 (간단한 계산)
      return locations.where((location) {
        var distance = _calculateDistance(
          latitude,
          longitude,
          location.latitude,
          location.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('주변 장소 조회 실패: $e');
    }
  }

  // 간단한 거리 계산 (하버사인 공식 근사)
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double radiusEarth = 6371; // 지구 반지름 (km)
    var dLat = _degreesToRadians(lat2 - lat1);
    var dLon = _degreesToRadians(lon2 - lon1);
    var a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radiusEarth * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// 사용자가 주소를 등록했는지 확인
  static Future<bool> hasUserRegisteredAddress(String userId) async {
    try {
      var response = await SupabaseService.client
          .from('locations')
          .select('id')
          .eq('user_id', userId)
          .eq('category', 'user_address')
          .eq('is_active', true)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

class KakaoAddressResult {
  const KakaoAddressResult({
    required this.address,
    this.roadAddress,
    required this.latitude,
    required this.longitude,
    this.buildingName,
  });

  factory KakaoAddressResult.fromJson(Map<String, dynamic> json) {
    return KakaoAddressResult(
      address: json['address_name'] as String,
      roadAddress:
          (json['road_address'] as Map<String, dynamic>?)?['address_name']
              as String?,
      latitude: double.parse(json['y'] as String),
      longitude: double.parse(json['x'] as String),
      buildingName:
          (json['road_address'] as Map<String, dynamic>?)?['building_name']
              as String?,
    );
  }

  final String address;
  final String? roadAddress;
  final double latitude;
  final double longitude;
  final String? buildingName;
}

class KakaoPlaceResult {
  const KakaoPlaceResult({
    required this.placeName,
    required this.address,
    this.roadAddress,
    required this.latitude,
    required this.longitude,
    this.categoryName,
  });

  factory KakaoPlaceResult.fromJson(Map<String, dynamic> json) {
    return KakaoPlaceResult(
      placeName: json['place_name'] as String,
      address: json['address_name'] as String,
      roadAddress: json['road_address_name'] as String?,
      latitude: double.parse(json['y'] as String),
      longitude: double.parse(json['x'] as String),
      categoryName: json['category_name'] as String?,
    );
  }

  final String placeName;
  final String address;
  final String? roadAddress;
  final double latitude;
  final double longitude;
  final String? categoryName;
}
