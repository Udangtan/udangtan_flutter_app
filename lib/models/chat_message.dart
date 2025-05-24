class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.timestamp,
    required this.isFromMe,
  });

  final String id;
  final String senderId;
  final String message;
  final DateTime timestamp;
  final bool isFromMe;

  // 샘플 채팅 메시지 (뽑뽑 채팅방에 맞춰 수정)
  static List<ChatMessage> getSampleMessages(String chatRoomId) {
    var now = DateTime.now();

    switch (chatRoomId) {
      case '1': // 뽑뽑 채팅방
        return [
          ChatMessage(
            id: '1',
            senderId: 'other',
            message: '안녕하세요😊',
            timestamp: now.subtract(const Duration(minutes: 7, seconds: 17)),
            isFromMe: false,
          ),
          ChatMessage(
            id: '2',
            senderId: 'me',
            message: '안녕하세요 !',
            timestamp: now.subtract(const Duration(minutes: 6, seconds: 22)),
            isFromMe: true,
          ),
          ChatMessage(
            id: '3',
            senderId: 'me',
            message: '강아지가 몇살인가요?',
            timestamp: now.subtract(const Duration(minutes: 5, seconds: 22)),
            isFromMe: true,
          ),
          ChatMessage(
            id: '4',
            senderId: 'other',
            message: '2살입니다 !',
            timestamp: now.subtract(const Duration(minutes: 4, seconds: 36)),
            isFromMe: false,
          ),
          ChatMessage(
            id: '5',
            senderId: 'other',
            message: '여름이는 몇살인가요?',
            timestamp: now.subtract(const Duration(minutes: 4, seconds: 36)),
            isFromMe: false,
          ),
          ChatMessage(
            id: '6',
            senderId: 'other',
            message: '괜찮으면 산책 같이 하실래요?',
            timestamp: now.subtract(const Duration(minutes: 3, seconds: 24)),
            isFromMe: false,
          ),
          ChatMessage(
            id: '7',
            senderId: 'me',
            message: '오.. 너무 좋은데요?!',
            timestamp: now.subtract(const Duration(minutes: 2, seconds: 29)),
            isFromMe: true,
          ),
          ChatMessage(
            id: '8',
            senderId: 'me',
            message: '어디서 주로 산책하시나요?',
            timestamp: now.subtract(const Duration(minutes: 1, seconds: 29)),
            isFromMe: true,
          ),
        ];
      default:
        return [
          ChatMessage(
            id: '1',
            senderId: 'other',
            message: '안녕하세요!',
            timestamp: now.subtract(const Duration(minutes: 10)),
            isFromMe: false,
          ),
          ChatMessage(
            id: '2',
            senderId: 'me',
            message: '안녕하세요!',
            timestamp: now.subtract(const Duration(minutes: 9)),
            isFromMe: true,
          ),
        ];
    }
  }

  // 시간 형식화 개선
  String get formattedTime {
    var hour = timestamp.hour;
    var minute = timestamp.minute;
    var period = hour >= 12 ? '오후' : '오전';
    var displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }
}
