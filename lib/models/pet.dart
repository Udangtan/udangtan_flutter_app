class Pet {
  const Pet({
    this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.profileImages,
    required this.personality,
    this.description,
    this.isNeutered,
    this.vaccinationStatus,
    this.weight,
    this.size,
    this.activityLevel,
    this.locationCity,
    this.locationDistrict,
    this.latitude,
    this.longitude,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.ownerProfileImage,
    this.ownerAddress,
    this.ownerCity,
    this.ownerDistrict,
    this.distanceKm,
    this.likedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int?,
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      species: json['species'] as String? ?? '',
      breed: json['breed'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      profileImages:
          (json['profile_images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      personality:
          (json['personality'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      description: json['description'] as String?,
      isNeutered: json['is_neutered'] as String?,
      vaccinationStatus: json['vaccination_status'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      size: json['size'] as String?,
      activityLevel: json['activity_level'] as String?,
      locationCity: json['location_city'] as String?,
      locationDistrict: json['location_district'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      ownerName: json['owner_name'] as String?,
      ownerProfileImage: json['owner_profile_image'] as String?,
      ownerAddress: json['owner_address'] as String?,
      ownerCity: json['owner_city'] as String?,
      ownerDistrict: json['owner_district'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      likedAt:
          json['liked_at'] != null
              ? DateTime.parse(json['liked_at'] as String)
              : null,
    );
  }

  final int? id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String gender;
  final List<String> profileImages;
  final List<String> personality;
  final String? description;
  final String? isNeutered; // '완료', '안함', '모름'
  final String? vaccinationStatus; // '완료', '미완료', '진행중', '모름'
  final double? weight;
  final String? size;
  final String? activityLevel;
  final String? locationCity;
  final String? locationDistrict;
  final double? latitude;
  final double? longitude;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Owner 정보 (JOIN 결과)
  final String? ownerName;
  final String? ownerProfileImage;
  final String? ownerAddress;
  final String? ownerCity;
  final String? ownerDistrict;
  final double? distanceKm;

  final DateTime? likedAt;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'owner_id': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'profile_images': profileImages,
      'personality': personality,
      if (description != null) 'description': description,
      if (isNeutered != null) 'is_neutered': isNeutered,
      if (vaccinationStatus != null) 'vaccination_status': vaccinationStatus,
      if (weight != null) 'weight': weight,
      if (size != null) 'size': size,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (locationCity != null) 'location_city': locationCity,
      if (locationDistrict != null) 'location_district': locationDistrict,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'is_available': isAvailable,
    };
  }

  Pet copyWith({
    int? id,
    String? ownerId,
    String? name,
    String? species,
    String? breed,
    int? age,
    String? gender,
    List<String>? profileImages,
    List<String>? personality,
    String? description,
    String? isNeutered,
    String? vaccinationStatus,
    double? weight,
    String? size,
    String? activityLevel,
    String? locationCity,
    String? locationDistrict,
    double? latitude,
    double? longitude,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerName,
    String? ownerProfileImage,
    String? ownerAddress,
    String? ownerCity,
    String? ownerDistrict,
    double? distanceKm,
    DateTime? likedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      profileImages: profileImages ?? this.profileImages,
      personality: personality ?? this.personality,
      description: description ?? this.description,
      isNeutered: isNeutered ?? this.isNeutered,
      vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
      weight: weight ?? this.weight,
      size: size ?? this.size,
      activityLevel: activityLevel ?? this.activityLevel,
      locationCity: locationCity ?? this.locationCity,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerName: ownerName ?? this.ownerName,
      ownerProfileImage: ownerProfileImage ?? this.ownerProfileImage,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      ownerCity: ownerCity ?? this.ownerCity,
      ownerDistrict: ownerDistrict ?? this.ownerDistrict,
      distanceKm: distanceKm ?? this.distanceKm,
      likedAt: likedAt ?? this.likedAt,
    );
  }

  @override
  String toString() {
    return 'Pet(id: $id, name: $name, species: $species, breed: $breed, age: $age)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pet && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  // Helper getters
  bool get isNeuteredComplete => isNeutered == '완료';
  bool get isVaccinated => vaccinationStatus == '완료';

  // 구버전 호환성을 위한 getter들 (deprecated)
  @Deprecated('Use isNeutered instead')
  bool? get isNeuteredOld =>
      isNeutered == '완료' ? true : (isNeutered == '안함' ? false : null);

  @Deprecated('Use vaccinationStatus instead')
  bool? get isVaccinatedOld =>
      vaccinationStatus == '완료'
          ? true
          : (vaccinationStatus == '미완료' ? false : null);

  static const List<String> personalityOptions = [
    '활발함',
    '조용함',
    '사교적',
    '독립적',
    '애교많음',
    '장난꾸러기',
    '온순함',
    '경계심많음',
    '호기심많음',
    '느긋함',
    '똑똑함',
    '고집셈',
    '친화적',
    '예민함',
    '용감함',
    '겁많음',
  ];

  static const List<String> ageRangeOptions = [
    '1살 미만',
    '1-3살',
    '4-7살',
    '8살 이상',
  ];

  static const List<String> sizeOptions = ['소형', '중형', '대형'];

  static const List<String> speciesOptions = ['강아지', '고양이'];

  static const List<String> activityLevelOptions = ['낮음', '보통', '높음'];
}
