class Location {
  const Location({
    this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.city,
    this.district,
    this.description,
    this.category,
    this.isActive = true,
    this.createdAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      city: json['city'] as String?,
      district: json['district'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }

  final int? id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? city;
  final String? district;
  final String? description;
  final String? category;
  final bool isActive;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'address': address,
      'city': city,
      'district': district,
      if (latitude != 0.0) 'latitude': latitude,
      if (longitude != 0.0) 'longitude': longitude,
      if (description != null) 'description': description,
      'is_active': isActive,
    };
  }

  String get categoryDisplayName {
    switch (category) {
      case 'hospital':
        return '동물병원';
      case 'petshop':
        return '펫샵';
      case 'cafe':
        return '펫카페';
      case 'park':
        return '공원';
      default:
        return category ?? '';
    }
  }

  @override
  String toString() {
    return 'Location(id: $id, name: $name, category: $category, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
