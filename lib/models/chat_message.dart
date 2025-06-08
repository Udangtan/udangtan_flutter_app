class ChatMessage {
  const ChatMessage({
    this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.message,
    this.messageType = 'text',
    this.isRead = false,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      chatRoomId: json['chat_room_id'],
      senderId: json['sender_id'] ?? '',
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? 'text',
      isRead: json['is_read'] ?? false,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  final int? id;
  final int chatRoomId;
  final String senderId;
  final String message;
  final String messageType;
  final bool isRead;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'message': message,
      'message_type': messageType,
      'is_read': isRead,
    };
  }

  bool isTextMessage() => messageType == 'text';
  bool isImageMessage() => messageType == 'image';
  bool isSystemMessage() => messageType == 'system';

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderId: $senderId, message: $message, messageType: $messageType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  // 샘플 채팅 메시지 (뽑뽑 채팅방에 맞춰 수정)
  static List<ChatMessage> getSampleMessages(String chatRoomId) {
    var now = DateTime.now();

    switch (chatRoomId) {
      case '1': // 뽑뽑 채팅방
        return [
          ChatMessage(
            id: 1,
            chatRoomId: 1,
            senderId: 'other',
            message: '안녕하세요😊',
            messageType: 'text',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 7, seconds: 17)),
          ),
          ChatMessage(
            id: 2,
            chatRoomId: 1,
            senderId: 'me',
            message: '안녕하세요 !',
            messageType: 'text',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 6, seconds: 22)),
          ),
          ChatMessage(
            id: 3,
            chatRoomId: 1,
            senderId: 'me',
            message: '강아지가 몇살인가요?',
            messageType: 'text',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 5, seconds: 22)),
          ),
          ChatMessage(
            id: 4,
            chatRoomId: 1,
            senderId: 'other',
            message: '2살입니다 !',
            messageType: 'text',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 4, seconds: 36)),
          ),
          ChatMessage(
            id: 5,
            chatRoomId: 1,
            senderId: 'other',
            message: '여름이는 몇살인가요?',
            messageType: 'text',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 4, seconds: 36)),
          ),
          ChatMessage(
            id: 6,
            chatRoomId: 1,
            senderId: 'other',
            message: '괜찮으면 산책 같이 하실래요?',
            messageType: 'text',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 3, seconds: 24)),
          ),
          ChatMessage(
            id: 7,
            chatRoomId: 1,
            senderId: 'me',
            message: '오.. 너무 좋은데요?!',
            messageType: 'text',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 2, seconds: 29)),
          ),
          ChatMessage(
            id: 8,
            chatRoomId: 1,
            senderId: 'me',
            message: '어디서 주로 산책하시나요?',
            messageType: 'text',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 1, seconds: 29)),
          ),
        ];
      default:
        return [
          ChatMessage(
            id: 1,
            chatRoomId: 1,
            senderId: 'other',
            message: '안녕하세요!',
            messageType: 'text',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 10)),
          ),
          ChatMessage(
            id: 2,
            chatRoomId: 1,
            senderId: 'me',
            message: '안녕하세요!',
            messageType: 'text',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 9)),
          ),
        ];
    }
  }

  // 시간 형식화 개선
  String get formattedTime {
    if (createdAt == null) return '';

    var hour = createdAt!.hour;
    var minute = createdAt!.minute;
    var period = hour >= 12 ? '오후' : '오전';
    var displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }
}
