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
    this.isVaccinated,
    this.weight,
    this.size,
    this.activityLevel,
    this.locationCity,
    this.locationDistrict,
    this.locationLatitude,
    this.locationLongitude,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.ownerProfileImage,
    this.ownerCity,
    this.ownerDistrict,
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
      isNeutered: json['is_neutered'] as bool?,
      isVaccinated: json['is_vaccinated'] as bool?,
      weight: (json['weight'] as num?)?.toDouble(),
      size: json['size'] as String?,
      activityLevel: json['activity_level'] as String?,
      locationCity: json['location_city'] as String?,
      locationDistrict: json['location_district'] as String?,
      locationLatitude: (json['location_latitude'] as num?)?.toDouble(),
      locationLongitude: (json['location_longitude'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
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
      ownerCity: json['owner_city'] as String?,
      ownerDistrict: json['owner_district'] as String?,
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
  final bool? isNeutered;
  final bool? isVaccinated;
  final double? weight;
  final String? size;
  final String? activityLevel;
  final String? locationCity;
  final String? locationDistrict;
  final double? locationLatitude;
  final double? locationLongitude;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? ownerName;
  final String? ownerProfileImage;
  final String? ownerCity;
  final String? ownerDistrict;

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
      if (isVaccinated != null) 'is_vaccinated': isVaccinated,
      if (weight != null) 'weight': weight,
      if (size != null) 'size': size,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (locationCity != null) 'location_city': locationCity,
      if (locationDistrict != null) 'location_district': locationDistrict,
      if (locationLatitude != null) 'location_latitude': locationLatitude,
      if (locationLongitude != null) 'location_longitude': locationLongitude,
      'is_active': isActive,
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
    bool? isNeutered,
    bool? isVaccinated,
    double? weight,
    String? size,
    String? activityLevel,
    String? locationCity,
    String? locationDistrict,
    double? locationLatitude,
    double? locationLongitude,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerName,
    String? ownerProfileImage,
    String? ownerCity,
    String? ownerDistrict,
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
      isVaccinated: isVaccinated ?? this.isVaccinated,
      weight: weight ?? this.weight,
      size: size ?? this.size,
      activityLevel: activityLevel ?? this.activityLevel,
      locationCity: locationCity ?? this.locationCity,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerName: ownerName ?? this.ownerName,
      ownerProfileImage: ownerProfileImage ?? this.ownerProfileImage,
      ownerCity: ownerCity ?? this.ownerCity,
      ownerDistrict: ownerDistrict ?? this.ownerDistrict,
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
