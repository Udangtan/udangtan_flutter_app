import 'package:udangtan_flutter_app/models/pet.dart';

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.otherUser,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isRead = false,
    this.unreadCount = 0,
  });

  final String id;
  final Pet otherUser;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isRead;
  final int unreadCount;

  static List<ChatRoom> get sampleChatRooms {
    var now = DateTime.now();

    return [
      ChatRoom(
        id: '1',
        otherUser: const Pet(
          id: '1',
          name: '뽑뽑',
          age: 3,
          location: '서울 강남구',
          distance: '300m',
          type: '강아지',
          imageUrl: 'assets/images/splash-image2.png',
          tags: ['🐾 활발이', '🎾 놀이꾼', '+2개'],
          allTags: ['🐾 활발이', '🎾 놀이꾼', '⚽ 공놀이', '🦴 간식러버'],
          description: '🎾 이 친구의 특징은',
        ),
        lastMessage: '안녕하세요',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        unreadCount: 1,
      ),
      ChatRoom(
        id: '2',
        otherUser: const Pet(
          id: '2',
          name: '초코',
          age: 2,
          location: '서울 서초구',
          distance: '500m',
          type: '강아지',
          imageUrl: 'assets/images/splash-image2.png',
          tags: ['😺 얌전이', '🐱 깔끔이', '+2개'],
          allTags: ['😺 얌전이', '🐱 깔끔이', '🛏️ 집콕파', '😴 낮잠림 있음'],
          description: '🐱 이 친구의 특징은',
        ),
        lastMessage: '오늘 저녁에 뭐하세요? 산책 하실 생각 있으세요...',
        lastMessageTime: now.subtract(const Duration(minutes: 21)),
        isRead: true,
        unreadCount: 0,
      ),
      ChatRoom(
        id: '3',
        otherUser: const Pet(
          id: '3',
          name: '꼬비',
          age: 4,
          location: '서울 종로구',
          distance: '800m',
          type: '고양이',
          imageUrl: 'assets/images/splash-image2.png',
          tags: ['🏃 활발이', '🎾 놀이꾼', '+4개'],
          allTags: [
            '🏃 활발이',
            '🎾 놀이꾼',
            '⚽ 공놀이',
            '🦴 간식러버',
            '🚿 목욕좋아',
            '💩 실외배변',
          ],
          description: '🎾 이 친구의 특징은',
        ),
        lastMessage: '간식 무료 나눔 합니다!',
        lastMessageTime: now.subtract(
          const Duration(days: 11, hours: 2, minutes: 26),
        ),
        isRead: true,
        unreadCount: 0,
      ),
      ChatRoom(
        id: '4',
        otherUser: const Pet(
          id: '4',
          name: '두식',
          age: 5,
          location: '서울 마포구',
          distance: '1.2km',
          type: '강아지',
          imageUrl: 'assets/images/splash-image2.png',
          tags: ['😴 잠꾸러기', '🐟 생선좋아', '+1개'],
          allTags: ['😴 잠꾸러기', '🐟 생선좋아', '🛏️ 집콕파'],
          description: '😴 이 친구의 특징은',
        ),
        lastMessage: '어디세요!',
        lastMessageTime: now.subtract(const Duration(days: 6, hours: 6)),
        isRead: true,
        unreadCount: 0,
      ),
      ChatRoom(
        id: '5',
        otherUser: const Pet(
          id: '5',
          name: '코코',
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
        lastMessage: '안녕하세요?',
        lastMessageTime: now.subtract(
          const Duration(days: 2, hours: 2, minutes: 26),
        ),
        isRead: true,
        unreadCount: 0,
      ),
      ChatRoom(
        id: '6',
        otherUser: const Pet(
          id: '6',
          name: '나비',
          age: 3,
          location: '서울 송파구',
          distance: '1.5km',
          type: '고양이',
          imageUrl: 'assets/images/splash-image2.png',
          tags: ['🐾 장난이', '🐶 훈련하기', '+3개'],
          allTags: ['🐾 장난이', '🐶 훈련하기', '⚽ 공놀이', '👕 옷입히기', '🏠 집콕파'],
          description: '❤️ 이 친구의 특징은',
        ),
        lastMessage: '안녕하세요?',
        lastMessageTime: now.subtract(
          const Duration(days: 2, hours: 2, minutes: 26),
        ),
        isRead: true,
        unreadCount: 0,
      ),
      ChatRoom(
        id: '7',
        otherUser: const Pet(
          id: '7',
          name: '안토니오',
          age: 4,
          location: '서울 용산구',
          distance: '3km',
          type: '강아지',
          imageUrl: 'assets/images/splash-image2.png',
          tags: ['😺 얌전이', '🐱 깔끔이', '+2개'],
          allTags: ['😺 얌전이', '🐱 깔끔이', '🛏️ 집콕파', '😴 낮잠림 있음'],
          description: '🐱 이 친구의 특징은',
        ),
        lastMessage: '안녕하세요?',
        lastMessageTime: now.subtract(
          const Duration(days: 2, hours: 2, minutes: 26),
        ),
        isRead: true,
        unreadCount: 0,
      ),
    ];
  }

  String get formattedTime {
    var now = DateTime.now();
    var difference = now.difference(lastMessageTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}일 전';
    } else {
      return '${lastMessageTime.month}월 ${lastMessageTime.day}일';
    }
  }
}
