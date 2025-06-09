class UserLocation {
  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      userId: json['user_id'] as String?,
      roadAddress: json['road_address'] as String?,
      jibunAddress: json['jibun_address'] as String?,
      buildingName: json['building_name'] as String?,
      detailAddress: json['detail_address'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  factory UserLocation.fromSupabase(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      userId: json['user_id'] as String?,
      roadAddress: json['road_address'] as String?,
      jibunAddress: json['jibun_address'] as String?,
      buildingName: json['building_name'] as String?,
      detailAddress: json['detail_address'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  // 사용자 주소용 생성자
  factory UserLocation.createUserAddress({
    required String userId,
    required String addressName,
    required String fullAddress,
    required String roadAddress,
    required String jibunAddress,
    required String city,
    required String district,
    required double latitude,
    required double longitude,
    String? buildingName,
    String? detailAddress,
    bool isDefault = false,
  }) {
    return UserLocation(
      id: 0, // 새로 생성될 때는 0
      name: addressName,
      category: 'user_address',
      address: fullAddress,
      city: city,
      district: district,
      latitude: latitude,
      longitude: longitude,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: userId,
      roadAddress: roadAddress,
      jibunAddress: jibunAddress,
      buildingName: buildingName,
      detailAddress: detailAddress,
      isDefault: isDefault,
    );
  }

  const UserLocation({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.city,
    required this.district,
    this.phone,
    this.website,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.userId,
    this.roadAddress,
    this.jibunAddress,
    this.buildingName,
    this.detailAddress,
    this.isDefault = false,
  });

  final int id;
  final String name; // 주소 별칭 (집, 회사 등)
  final String category; // 'user_address' (사용자 주소 구분용)
  final String address; // 전체 주소
  final String city; // 시/도
  final String district; // 구/군
  final String? phone; // 전화번호 (선택)
  final String? website; // 웹사이트 (선택)
  final double latitude; // 위도
  final double longitude; // 경도
  final double? rating; // 평점 (선택)
  final String? description; // 상세 주소/설명
  final bool isActive; // 활성 상태
  final DateTime createdAt;
  final DateTime? updatedAt;

  // 사용자 주소 전용 필드 (실제 컬럼)
  final String? userId;
  final String? roadAddress;
  final String? jibunAddress;
  final String? buildingName;
  final String? detailAddress;
  final bool isDefault;

  UserLocation copyWith({
    int? id,
    String? name,
    String? category,
    String? address,
    String? city,
    String? district,
    String? phone,
    String? website,
    double? latitude,
    double? longitude,
    double? rating,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? roadAddress,
    String? jibunAddress,
    String? buildingName,
    String? detailAddress,
    bool? isDefault,
  }) {
    return UserLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      roadAddress: roadAddress ?? this.roadAddress,
      jibunAddress: jibunAddress ?? this.jibunAddress,
      buildingName: buildingName ?? this.buildingName,
      detailAddress: detailAddress ?? this.detailAddress,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'category': category,
      'address': address,
      'city': city,
      'district': district,
      'phone': phone,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'description': description,
      'is_active': isActive,
      'user_id': userId,
      'road_address': roadAddress,
      'jibun_address': jibunAddress,
      'building_name': buildingName,
      'detail_address': detailAddress,
      'is_default': isDefault,
    };

    // id가 0이 아닌 경우에만 포함 (업데이트 시)
    if (id != 0) {
      json['id'] = id;
    }

    return json;
  }

  Map<String, dynamic> toSupabaseInsert() {
    var addressParts = address.split(' ');
    var city = addressParts.isNotEmpty ? addressParts[0] : '';
    var district = addressParts.length > 1 ? addressParts[1] : '';

    return <String, dynamic>{
      'name': name,
      'category': 'user_address',
      'address': address,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': true,
      'user_id': userId,
      'road_address': roadAddress,
      'jibun_address': jibunAddress,
      'building_name': buildingName,
      'detail_address': detailAddress,
      'is_default': isDefault,
    };
  }

  Map<String, dynamic> toSupabaseUpdate() {
    var addressParts = address.split(' ');
    var city = addressParts.isNotEmpty ? addressParts[0] : '';
    var district = addressParts.length > 1 ? addressParts[1] : '';

    return <String, dynamic>{
      'name': name,
      'address': address,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'road_address': roadAddress,
      'jibun_address': jibunAddress,
      'building_name': buildingName,
      'detail_address': detailAddress,
      'is_default': isDefault,
    };
  }
}
