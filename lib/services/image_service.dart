import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';

class ImageService {
  static Future<String> uploadPetImage(File imageFile, int petId) async {
    try {
      var userId = AuthService.getCurrentUserId();
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 파일 확장자 확인
      var extension = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        throw Exception('지원되지 않는 이미지 형식입니다. (JPG, PNG, WEBP만 지원)');
      }

      // 파일 크기 확인 (10MB 제한)
      var fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('이미지 크기는 10MB 이하여야 합니다');
      }

      // 고유한 파일명 생성
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var fileName = 'pet_${petId}_${timestamp}.$extension';
      var filePath = 'pets/$userId/$fileName';

      // 기존 이미지가 있다면 삭제
      await _deleteOldPetImage(petId);

      // 이미지 업로드
      await SupabaseService.client.storage
          .from('pet-images')
          .upload(filePath, imageFile);

      // 공개 URL 생성
      var publicUrl = SupabaseService.client.storage
          .from('pet-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  static Future<String> uploadPetImageFromBytes(
    Uint8List imageBytes,
    int petId,
    String fileName,
  ) async {
    try {
      var userId = AuthService.getCurrentUserId();
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 파일 확장자 확인
      var extension = fileName.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        throw Exception('지원되지 않는 이미지 형식입니다. (JPG, PNG, WEBP만 지원)');
      }

      // 파일 크기 확인 (10MB 제한)
      if (imageBytes.length > 10 * 1024 * 1024) {
        throw Exception('이미지 크기는 10MB 이하여야 합니다');
      }

      // 고유한 파일명 생성
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var newFileName = 'pet_${petId}_${timestamp}.$extension';
      var filePath = 'pets/$userId/$newFileName';

      // 기존 이미지가 있다면 삭제
      await _deleteOldPetImage(petId);

      // 이미지 업로드
      await SupabaseService.client.storage
          .from('pet-images')
          .uploadBinary(filePath, imageBytes);

      // 공개 URL 생성
      var publicUrl = SupabaseService.client.storage
          .from('pet-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  static Future<void> _deleteOldPetImage(int petId) async {
    try {
      // 기존 펫 정보에서 이미지 URL 가져오기
      var petResponse =
          await SupabaseService.client
              .from('pets')
              .select('profile_images')
              .eq('id', petId)
              .maybeSingle();

      if (petResponse != null && petResponse['profile_images'] != null) {
        var profileImages = petResponse['profile_images'] as List<dynamic>;
        if (profileImages.isNotEmpty) {
          var imageUrl = profileImages.first as String;
          // URL에서 파일 경로 추출
          var uri = Uri.parse(imageUrl);
          var pathSegments = uri.pathSegments;
          if (pathSegments.length >= 3) {
            var filePath = pathSegments.sublist(2).join('/');
            await SupabaseService.client.storage.from('pet-images').remove([
              filePath,
            ]);
          }
        }
      }
    } catch (e) {
      // 기존 이미지 삭제 실패는 무시 (새 이미지 업로드는 계속 진행)
      if (kDebugMode) {
        print('기존 이미지 삭제 실패: $e');
      }
    }
  }

  static Future<String> uploadUserProfileImage(
    File imageFile,
    String userId,
  ) async {
    try {
      // 파일 확장자 확인
      var extension = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        throw Exception('지원되지 않는 이미지 형식입니다. (JPG, PNG, WEBP만 지원)');
      }

      // 파일 크기 확인 (5MB 제한)
      var fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('이미지 크기는 5MB 이하여야 합니다');
      }

      // 고유한 파일명 생성
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var fileName = 'profile_${userId}_${timestamp}.$extension';
      var filePath = 'users/$userId/$fileName';

      // 이미지 업로드
      await SupabaseService.client.storage
          .from('user-images')
          .upload(filePath, imageFile);

      // 공개 URL 생성
      var publicUrl = SupabaseService.client.storage
          .from('user-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('프로필 이미지 업로드 실패: $e');
    }
  }

  static Future<void> deletePetImage(String imageUrl) async {
    try {
      // URL에서 파일 경로 추출
      var uri = Uri.parse(imageUrl);
      var pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3) {
        var filePath = pathSegments.sublist(2).join('/');
        await SupabaseService.client.storage.from('pet-images').remove([
          filePath,
        ]);
      }
    } catch (e) {
      throw Exception('이미지 삭제 실패: $e');
    }
  }

  static Future<void> deleteUserProfileImage(String imageUrl) async {
    try {
      // URL에서 파일 경로 추출
      var uri = Uri.parse(imageUrl);
      var pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3) {
        var filePath = pathSegments.sublist(2).join('/');
        await SupabaseService.client.storage.from('user-images').remove([
          filePath,
        ]);
      }
    } catch (e) {
      throw Exception('프로필 이미지 삭제 실패: $e');
    }
  }
}

// TODO Implement this library.
