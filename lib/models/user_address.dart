class UserAddress {
  UserAddress({
    required this.id,
    required this.userId,
    required this.addressName,
    required this.fullAddress,
    required this.roadAddress,
    required this.jibunAddress,
    required this.latitude,
    required this.longitude,
    this.buildingName,
    this.detailAddress,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      addressName: json['address_name'] as String,
      fullAddress: json['full_address'] as String,
      roadAddress: json['road_address'] as String,
      jibunAddress: json['jibun_address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      buildingName: json['building_name'] as String?,
      detailAddress: json['detail_address'] as String?,
      isDefault: json['is_default'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String addressName; // 주소 별칭 (예: 집, 회사)
  final String fullAddress; // 전체 주소
  final String roadAddress; // 도로명 주소
  final String jibunAddress; // 지번 주소
  final double latitude; // 위도
  final double longitude; // 경도
  final String? buildingName; // 건물명
  final String? detailAddress; // 상세 주소
  final bool isDefault; // 기본 주소 여부
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAddress copyWith({
    String? id,
    String? userId,
    String? addressName,
    String? fullAddress,
    String? roadAddress,
    String? jibunAddress,
    double? latitude,
    double? longitude,
    String? buildingName,
    String? detailAddress,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      addressName: addressName ?? this.addressName,
      fullAddress: fullAddress ?? this.fullAddress,
      roadAddress: roadAddress ?? this.roadAddress,
      jibunAddress: jibunAddress ?? this.jibunAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      buildingName: buildingName ?? this.buildingName,
      detailAddress: detailAddress ?? this.detailAddress,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'address_name': addressName,
      'full_address': fullAddress,
      'road_address': roadAddress,
      'jibun_address': jibunAddress,
      'latitude': latitude,
      'longitude': longitude,
      'building_name': buildingName,
      'detail_address': detailAddress,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
