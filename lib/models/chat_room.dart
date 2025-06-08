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
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
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
    );
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

  @override
  String toString() {
    return 'ChatRoom(id: $id, user1Id: $user1Id, user2Id: $user2Id, lastMessage: $lastMessage)';
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
