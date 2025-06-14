class ChatRoom {
  const ChatRoom({
    this.id,
    this.matchId,
    required this.user1Id,
    required this.user2Id,
    this.lastMessage,
    this.lastMessageAt,
    this.isActive = true,
    this.createdAt,
    this.user1Name,
    this.user1ProfileImage,
    this.user2Name,
    this.user2ProfileImage,
    this.pet1Id,
    this.pet2Id,
    this.pet1Name,
    this.pet2Name,
    this.chatType,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    var chatRoom = ChatRoom(
      id: json['id'],
      matchId: json['match_id'],
      user1Id: json['user1_id'] ?? '',
      user2Id: json['user2_id'] ?? '',
      lastMessage: json['last_message'],
      lastMessageAt:
          json['last_message_at'] != null
              ? DateTime.parse(json['last_message_at'])
              : null,
      isActive: json['is_active'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      user1Name: json['user1_name'],
      user1ProfileImage: json['user1_profile_image'],
      user2Name: json['user2_name'],
      user2ProfileImage: json['user2_profile_image'],
      pet1Id: json['pet1_id'],
      pet2Id: json['pet2_id'],
      pet1Name: json['pet1_name'],
      pet2Name: json['pet2_name'],
      chatType: json['chat_type'],
    );

    return chatRoom;
  }

  final int? id;
  final int? matchId;
  final String user1Id;
  final String user2Id;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isActive;
  final DateTime? createdAt;

  // 뷰에서 오는 추가 필드들
  final String? user1Name;
  final String? user1ProfileImage;
  final String? user2Name;
  final String? user2ProfileImage;

  // 펫 정보 필드들
  final int? pet1Id;
  final int? pet2Id;
  final String? pet1Name;
  final String? pet2Name;
  final String? chatType;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      'user1_id': user1Id,
      'user2_id': user2Id,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageAt != null)
        'last_message_at': lastMessageAt!.toIso8601String(),
      'is_active': isActive,
      if (pet1Id != null) 'pet1_id': pet1Id,
      if (pet2Id != null) 'pet2_id': pet2Id,
      if (chatType != null) 'chat_type': chatType,
    };
  }

  String getOtherUserName(String currentUserId) {
    if (currentUserId == user1Id) {
      return user2Name ?? '알 수 없음';
    } else {
      return user1Name ?? '알 수 없음';
    }
  }

  String? getOtherUserProfileImage(String currentUserId) {
    if (currentUserId == user1Id) {
      return user2ProfileImage;
    } else {
      return user1ProfileImage;
    }
  }

  // 상대방 펫 이름 가져오기
  String getOtherPetName(String currentUserId) {
    if (currentUserId == user1Id) {
      return pet2Name ?? '알 수 없는 펫';
    } else {
      return pet1Name ?? '알 수 없는 펫';
    }
  }

  // 내 펫 이름 가져오기
  String getMyPetName(String currentUserId) {
    if (currentUserId == user1Id) {
      return pet1Name ?? '내 펫';
    } else {
      return pet2Name ?? '내 펫';
    }
  }

  @override
  String toString() {
    return 'ChatRoom(id: $id, user1Id: $user1Id, user2Id: $user2Id, pet1Name: $pet1Name, pet2Name: $pet2Name, lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoom && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
