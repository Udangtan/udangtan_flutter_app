import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:udangtan_flutter_app/models/location.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    var permission = await Permission.location.request();
    return permission == PermissionStatus.granted;
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  static Future<List<Location>> getNearbyLocations({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  }) async {
    try {
      var response = await SupabaseService.client
          .from('locations')
          .select()
          .eq('is_active', true)
          .order('name');

      var locations =
          response.map<Location>((json) => Location.fromJson(json)).toList();

      // 거리 계산해서 필터링
      var nearbyLocations =
          locations.where((location) {
            if (location.latitude == 0.0 || location.longitude == 0.0) {
              return false;
            }

            var distance = calculateDistance(
              latitude,
              longitude,
              location.latitude,
              location.longitude,
            );

            return distance <= radiusInKm * 1000; // km를 m로 변환
          }).toList();

      // 거리순으로 정렬
      nearbyLocations.sort((a, b) {
        var distanceA = calculateDistance(
          latitude,
          longitude,
          a.latitude,
          a.longitude,
        );
        var distanceB = calculateDistance(
          latitude,
          longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      return nearbyLocations;
    } catch (error) {
      return [];
    }
  }

  static Future<List<Location>> getAllLocations() async {
    try {
      var response = await SupabaseService.client
          .from('locations')
          .select()
          .eq('is_active', true)
          .order('name');

      return response.map<Location>((json) => Location.fromJson(json)).toList();
    } catch (error) {
      return [];
    }
  }

  static Future<List<Location>> getLocationsByCategory(String category) async {
    try {
      var response = await SupabaseService.client
          .from('locations')
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('name');

      return response
          .map<Location>((locationData) => Location.fromJson(locationData))
          .toList();
    } catch (error) {
      return [];
    }
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      double km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }
}
