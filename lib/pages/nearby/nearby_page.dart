import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:udangtan_flutter_app/models/location.dart';
import 'package:udangtan_flutter_app/services/location_service.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  Position? _currentPosition;
  List<Location> _nearbyLocations = [];
  bool _isLoading = true;
  bool _hasLocationError = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocationAndNearby();
  }

  Future<void> _loadCurrentLocationAndNearby() async {
    setState(() => _isLoading = true);

    try {
      _currentPosition = await LocationService.getCurrentLocation();
      if (_currentPosition != null) {
        _nearbyLocations = await LocationService.getNearbyLocations(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          radiusInKm: 5.0,
        );
        setState(() {
          _hasLocationError = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasLocationError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasLocationError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내 주변',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadCurrentLocationAndNearby,
            icon: const Icon(Icons.refresh, color: Color(0xFF6C5CE7)),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
              )
              : _hasLocationError
              ? _buildLocationErrorWidget()
              : _buildLocationListWidget(),
    );
  }

  Widget _buildLocationErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            '위치 정보를 가져올 수 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '위치 권한을 허용하고 GPS를 켜주세요',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _loadCurrentLocationAndNearby,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              '다시 시도',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationListWidget() {
    return Column(
      children: [
        if (_currentPosition != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '현재 위치',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '위도: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '경도: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '주변 장소 (${_nearbyLocations.length}개)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _showCategoryDialog,
                child: const Text(
                  '카테고리 선택',
                  style: TextStyle(color: Color(0xFF6C5CE7)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _nearbyLocations.isEmpty
                  ? const Center(
                    child: Text(
                      '주변에 등록된 장소가 없습니다',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    itemCount: _nearbyLocations.length,
                    itemBuilder: (context, index) {
                      var location = _nearbyLocations[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF6C5CE7),
                            child: Icon(
                              _getCategoryIcon(location.category ?? ''),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            location.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(location.address),
                              const SizedBox(height: 4),
                              Text(
                                location.category ?? '기타',
                                style: const TextStyle(
                                  color: Color(0xFF6C5CE7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            _showLocationDetail(location);
                          },
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hospital':
      case '동물병원':
        return Icons.local_hospital;
      case 'petshop':
      case '펫샵':
        return Icons.store;
      case 'park':
      case '공원':
        return Icons.park;
      case 'cafe':
      case '카페':
        return Icons.local_cafe;
      default:
        return Icons.place;
    }
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카테고리 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategoryOption('전체', Icons.list, 'all'),
              _buildCategoryOption('동물병원', Icons.local_hospital, 'hospital'),
              _buildCategoryOption('펫샵', Icons.store, 'petshop'),
              _buildCategoryOption('공원', Icons.park, 'park'),
              _buildCategoryOption('카페', Icons.local_cafe, 'cafe'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryOption(String title, IconData icon, String category) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6C5CE7)),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        _loadLocationsByCategory(category);
      },
    );
  }

  Future<void> _loadLocationsByCategory(String category) async {
    setState(() => _isLoading = true);

    try {
      List<Location> locations;
      if (category == 'all') {
        if (_currentPosition != null) {
          locations = await LocationService.getNearbyLocations(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            radiusInKm: 10.0,
          );
        } else {
          locations = await LocationService.getAllLocations();
        }
      } else {
        locations = await LocationService.getAllLocations();
        locations =
            locations
                .where(
                  (loc) =>
                      (loc.category ?? '').toLowerCase() ==
                      category.toLowerCase(),
                )
                .toList();
      }

      setState(() {
        _nearbyLocations = locations;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('장소를 불러오는데 실패했습니다: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLocationDetail(Location location) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(location.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('주소: ${location.address}'),
              const SizedBox(height: 8),
              Text('카테고리: ${location.category ?? '기타'}'),
              const SizedBox(height: 8),
              if (location.description != null &&
                  location.description!.isNotEmpty)
                Text('설명: ${location.description}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}
