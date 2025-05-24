class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.age,
    required this.location,
    required this.distance,
    required this.type,
    required this.imageUrl,
    required this.tags,
    required this.allTags,
    required this.description,
    this.gender,
    this.breed,
    this.personalities = const [],
    this.ageRange,
    this.isMyPet = false,
  });

  final String id;
  final String name;
  final int age;
  final String location;
  final String distance;
  final String type; // '강아지' or '고양이'
  final String imageUrl;
  final List<String> tags;
  final List<String> allTags;
  final String description;
  final String? gender; // '수컷' or '암컷'
  final String? breed; // 품종
  final List<String> personalities; // 성격들
  final String? ageRange; // '1살 미만', '1-3살', '4-7살', '8살 이상'
  final bool isMyPet; // 내 반려동물 여부

  Pet copyWith({
    String? id,
    String? name,
    int? age,
    String? location,
    String? distance,
    String? type,
    String? imageUrl,
    List<String>? tags,
    List<String>? allTags,
    String? description,
    String? gender,
    String? breed,
    List<String>? personalities,
    String? ageRange,
    bool? isMyPet,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      allTags: allTags ?? this.allTags,
      description: description ?? this.description,
      gender: gender ?? this.gender,
      breed: breed ?? this.breed,
      personalities: personalities ?? this.personalities,
      ageRange: ageRange ?? this.ageRange,
      isMyPet: isMyPet ?? this.isMyPet,
    );
  }

  // 반려동물 성격 옵션들
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

  // 나이 구간 옵션들
  static const List<String> ageRangeOptions = [
    '1살 미만',
    '1-3살',
    '4-7살',
    '8살 이상',
  ];

  // 샘플 데이터
  static Pet get sample => const Pet(
    id: '1',
    name: '김마루',
    age: 5,
    location: '서울 강동구',
    distance: '300m',
    type: '강아지',
    imageUrl: 'assets/images/splash-image2.png',
    tags: ['🐾 장난이', '🐶 훈련하기', '+3개'],
    allTags: ['🐾 장난이', '🐶 훈련하기', '⚽ 공놀이', '👕 옷입히기', '🏠 집콕파'],
    description: '❤️ 이 친구의 특징은',
    gender: '수컷',
    breed: '골든 리트리버',
    personalities: ['활발함', '사교적', '애교많음'],
    ageRange: '4-7살',
  );

  // 내 반려동물 샘플 데이터
  static const List<Pet> myPets = [
    Pet(
      id: 'my1',
      name: '김마루',
      age: 5,
      location: '서울 강동구',
      distance: '0m',
      type: '강아지',
      imageUrl: 'assets/images/splash-image2.png',
      tags: ['🐾 활발함', '🎾 사교적', '+1개'],
      allTags: ['🐾 활발함', '🎾 사교적', '💕 애교많음'],
      description: '우리 마루는 정말 활발하고 사교적이에요!',
      gender: '수컷',
      breed: '골든 리트리버',
      personalities: ['활발함', '사교적', '애교많음'],
      ageRange: '4-7살',
      isMyPet: true,
    ),
    Pet(
      id: 'my2',
      name: '나비',
      age: 3,
      location: '서울 강동구',
      distance: '0m',
      type: '고양이',
      imageUrl: 'assets/images/splash-image2.png',
      tags: ['😺 조용함', '🐱 독립적', '+1개'],
      allTags: ['😺 조용함', '🐱 독립적', '🛏️ 온순함'],
      description: '나비는 조용하고 독립적인 성격이에요.',
      gender: '암컷',
      breed: '페르시안',
      personalities: ['조용함', '독립적', '온순함'],
      ageRange: '1-3살',
      isMyPet: true,
    ),
  ];

  // 더 많은 샘플 데이터
  static const List<Pet> samplePets = [
    Pet(
      id: '1',
      name: '김마루',
      age: 3,
      location: '서울 강남구',
      distance: '300m',
      type: '강아지',
      imageUrl: 'assets/images/splash-image2.png',
      tags: ['🐾 활발이', '🎾 놀이꾼', '+2개'],
      allTags: ['🐾 활발이', '🎾 놀이꾼', '⚽ 공놀이', '🦴 간식러버'],
      description: '🎾 이 친구의 특징은',
    ),
    Pet(
      id: '2',
      name: '꼬꼬',
      age: 2,
      location: '서울 서초구',
      distance: '500m',
      type: '강아지',
      imageUrl: 'assets/images/splash-image2.png',
      tags: ['😺 얌전이', '🐱 깔끔이', '+2개'],
      allTags: ['😺 얌전이', '🐱 깔끔이', '🛏️ 집콕파', '😴 낮잠림 있음'],
      description: '🐱 이 친구의 특징은',
    ),
    Pet(
      id: '3',
      name: '몽이',
      age: 4,
      location: '서울 종로구',
      distance: '800m',
      type: '고양이',
      imageUrl: 'assets/images/splash-image2.png',
      tags: ['🏃 활발이', '🎾 놀이꾼', '+4개'],
      allTags: ['🏃 활발이', '🎾 놀이꾼', '⚽ 공놀이', '🦴 간식러버', '🚿 목욕좋아', '💩 실외배변'],
      description: '🎾 이 친구의 특징은',
    ),
    Pet(
      id: '4',
      name: '루이',
      age: 5,
      location: '서울 마포구',
      distance: '1.2km',
      type: '강아지',
      imageUrl: 'assets/images/splash-image2.png',
      tags: ['😴 잠꾸러기', '🐟 생선좋아', '+1개'],
      allTags: ['😴 잠꾸러기', '🐟 생선좋아', '🛏️ 집콕파'],
      description: '😴 이 친구의 특징은',
    ),
    Pet(
      id: '5',
      name: '보리',
      age: 6,
      location: '서울 강동구',
      distance: '2km',
      type: '강아지',
      imageUrl: 'assets/images/splash-image2.png',
      tags: ['🧠 똑똑이', '🦴 간식러버', '+5개'],
      allTags: [
        '🧠 똑똑이',
        '🦴 간식러버',
        '⚽ 공놀이',
        '👕 옷입히기',
        '🏠 집콕파',
        '😴 낮잠림 있음',
        '💩 실외배변',
      ],
      description: '🧠 이 친구의 특징은',
    ),
  ];
}
