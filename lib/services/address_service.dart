import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udangtan_flutter_app/app/env_config.dart';
import 'package:udangtan_flutter_app/models/user_address.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';

// 카카오 주소 검색 결과 모델
class KakaoAddressResult {
  KakaoAddressResult({
    required this.address,
    this.roadAddress,
    required this.latitude,
    required this.longitude,
    this.buildingName,
  });

  factory KakaoAddressResult.fromJson(Map<String, dynamic> json) {
    var address = json['address'] as Map<String, dynamic>;
    var roadAddress = json['road_address'] as Map<String, dynamic>?;

    return KakaoAddressResult(
      address: address['address_name'] as String? ?? '',
      roadAddress: roadAddress?['address_name'] as String?,
      latitude: double.parse(address['y'] as String? ?? '0'),
      longitude: double.parse(address['x'] as String? ?? '0'),
      buildingName: roadAddress?['building_name'] as String?,
    );
  }

  final String address;
  final String? roadAddress;
  final double latitude;
  final double longitude;
  final String? buildingName;
}

// 카카오 장소 검색 결과 모델
class KakaoPlaceResult {
  KakaoPlaceResult({
    required this.placeName,
    required this.address,
    this.roadAddress,
    required this.latitude,
    required this.longitude,
    this.categoryName,
  });

  factory KakaoPlaceResult.fromJson(Map<String, dynamic> json) {
    return KakaoPlaceResult(
      placeName: json['place_name'] as String? ?? '',
      address: json['address_name'] as String? ?? '',
      roadAddress: json['road_address_name'] as String?,
      latitude: double.parse(json['y'] as String? ?? '0'),
      longitude: double.parse(json['x'] as String? ?? '0'),
      categoryName: json['category_group_name'] as String?,
    );
  }

  final String placeName;
  final String address;
  final String? roadAddress;
  final double latitude;
  final double longitude;
  final String? categoryName;
}

class AddressService {
  static String get _kakaoRestApiKey => EnvConfig.kakaoRestApiKey;
  static const String _searchAddressUrl =
      'https://dapi.kakao.com/v2/local/search/address.json';
  static const String _searchKeywordUrl =
      'https://dapi.kakao.com/v2/local/search/keyword.json';

  // 카카오 주소 검색 모델
  static Future<List<KakaoAddressResult>> searchAddress(String query) async {
    try {
      var response = await http.get(
        Uri.parse('$_searchAddressUrl?query=${Uri.encodeComponent(query)}'),
        headers: {'Authorization': 'KakaoAK $_kakaoRestApiKey'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body) as Map<String, dynamic>;
        var documents = data['documents'] as List;

        return documents
            .map(
              (doc) => KakaoAddressResult.fromJson(doc as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('주소 검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('주소 검색 중 오류 발생: $e');
    }
  }

  // 키워드로 장소 검색
  static Future<List<KakaoPlaceResult>> searchPlace(String query) async {
    try {
      var response = await http.get(
        Uri.parse('$_searchKeywordUrl?query=${Uri.encodeComponent(query)}'),
        headers: {'Authorization': 'KakaoAK $_kakaoRestApiKey'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body) as Map<String, dynamic>;
        var documents = data['documents'] as List;

        return documents
            .map(
              (doc) => KakaoPlaceResult.fromJson(doc as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('장소 검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('장소 검색 중 오류 발생: $e');
    }
  }

  // 사용자 주소 목록 조회
  static Future<List<UserAddress>> getUserAddresses(String userId) async {
    try {
      var response = await SupabaseService.client
          .from('user_addresses')
          .select('*')
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserAddress.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('주소 목록 조회 실패: $e');
    }
  }

  // 기본 주소 조회
  static Future<UserAddress?> getDefaultAddress(String userId) async {
    try {
      var response =
          await SupabaseService.client
              .from('user_addresses')
              .select('*')
              .eq('user_id', userId)
              .eq('is_default', true)
              .maybeSingle();

      return response != null ? UserAddress.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  // 주소 추가
  static Future<UserAddress> addAddress(UserAddress address) async {
    try {
      // 새 주소가 기본 주소로 설정되는 경우, 기존 기본 주소 해제
      if (address.isDefault) {
        await _clearDefaultAddress(address.userId);
      }

      var response =
          await SupabaseService.client
              .from('user_addresses')
              .insert(address.toJson())
              .select()
              .single();

      return UserAddress.fromJson(response);
    } catch (e) {
      throw Exception('주소 추가 실패: $e');
    }
  }

  // 주소 수정
  static Future<UserAddress> updateAddress(UserAddress address) async {
    try {
      // 기본 주소로 변경되는 경우, 기존 기본 주소 해제
      if (address.isDefault) {
        await _clearDefaultAddress(address.userId);
      }

      var response =
          await SupabaseService.client
              .from('user_addresses')
              .update(address.toJson())
              .eq('id', address.id)
              .select()
              .single();

      return UserAddress.fromJson(response);
    } catch (e) {
      throw Exception('주소 수정 실패: $e');
    }
  }

  // 주소 삭제
  static Future<void> deleteAddress(String addressId) async {
    try {
      await SupabaseService.client
          .from('user_addresses')
          .delete()
          .eq('id', addressId);
    } catch (e) {
      throw Exception('주소 삭제 실패: $e');
    }
  }

  // 기본 주소 설정
  static Future<void> setDefaultAddress(String addressId, String userId) async {
    try {
      await _clearDefaultAddress(userId);

      await SupabaseService.client
          .from('user_addresses')
          .update({
            'is_default': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', addressId);
    } catch (e) {
      throw Exception('기본 주소 설정 실패: $e');
    }
  }

  // 기존 기본 주소 해제
  static Future<void> _clearDefaultAddress(String userId) async {
    await SupabaseService.client
        .from('user_addresses')
        .update({
          'is_default': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('is_default', true);
  }

  // 주소 검색 결과를 UserAddress로 변환
  static UserAddress createUserAddressFromKakao({
    required String userId,
    required String addressName,
    required KakaoAddressResult kakaoResult,
    String? detailAddress,
    bool isDefault = false,
  }) {
    var now = DateTime.now();
    return UserAddress(
      id: '', // Supabase에서 자동 생성
      userId: userId,
      addressName: addressName,
      fullAddress: kakaoResult.address,
      roadAddress: kakaoResult.roadAddress ?? kakaoResult.address,
      jibunAddress: kakaoResult.address,
      latitude: kakaoResult.latitude,
      longitude: kakaoResult.longitude,
      buildingName: kakaoResult.buildingName,
      detailAddress: detailAddress,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );
  }

  // 장소 검색 결과를 UserAddress로 변환
  static UserAddress createUserAddressFromPlace({
    required String userId,
    required String addressName,
    required KakaoPlaceResult placeResult,
    String? detailAddress,
    bool isDefault = false,
  }) {
    var now = DateTime.now();
    return UserAddress(
      id: '', // Supabase에서 자동 생성
      userId: userId,
      addressName: addressName,
      fullAddress: placeResult.roadAddress ?? placeResult.address,
      roadAddress: placeResult.roadAddress ?? placeResult.address,
      jibunAddress: placeResult.address,
      latitude: placeResult.latitude,
      longitude: placeResult.longitude,
      buildingName: placeResult.placeName,
      detailAddress: detailAddress,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );
  }
}
