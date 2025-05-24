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
  });

  final String id;
  final String name;
  final int age;
  final String location;
  final String distance;
  final String type;
  final String imageUrl;
  final List<String> tags;
  final List<String> allTags;
  final String description;

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
  );

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
