import 'package:udangtan_flutter_app/models/chat_message.dart';
import 'package:udangtan_flutter_app/models/chat_room.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';

class ChatService {
  static Future<List<ChatRoom>> getChatRooms(String userId) async {
    try {
      print('=== getChatRooms 시작 ===');
      print('userId: $userId');

      var response = await SupabaseService.client
          .from('chat_rooms_with_users')
          .select('*')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .eq('is_active', true)
          .order('last_message_at', ascending: false);

      print('조회된 채팅방 개수: ${response.length}');

      for (int i = 0; i < response.length; i++) {
        var roomData = response[i];
        print('--- 채팅방 $i ---');
        print('ID: ${roomData['id']}');
        print('user1_id: ${roomData['user1_id']}');
        print('user2_id: ${roomData['user2_id']}');
        print('user1_name: ${roomData['user1_name']}');
        print('user2_name: ${roomData['user2_name']}');
        print('pet1_id: ${roomData['pet1_id']}');
        print('pet2_id: ${roomData['pet2_id']}');
        print('pet1_name: ${roomData['pet1_name']}');
        print('pet2_name: ${roomData['pet2_name']}');
        print('last_message: ${roomData['last_message']}');
        print('---');
      }

      var chatRooms =
          response.map<ChatRoom>((json) => ChatRoom.fromJson(json)).toList();

      print('변환된 ChatRoom 객체들:');
      for (var room in chatRooms) {
        print('ChatRoom: ${room.toString()}');
      }

      print('=== getChatRooms 완료 ===');
      return chatRooms;
    } catch (error) {
      print('getChatRooms 에러: $error');
      return [];
    }
  }

  static Future<ChatRoom?> createChatRoom({
    required String user1Id,
    required String user2Id,
    int? matchId,
  }) async {
    try {
      var response =
          await SupabaseService.client
              .from('chat_rooms')
              .insert({
                'user1_id': user1Id,
                'user2_id': user2Id,
                if (matchId != null) 'match_id': matchId,
              })
              .select()
              .single();

      return ChatRoom.fromJson(response);
    } catch (error) {
      return null;
    }
  }

  static Future<ChatRoom?> findOrCreatePetChatRoom({
    required String currentUserId,
    required int targetPetId,
  }) async {
    try {
      print('=== findOrCreatePetChatRoom 시작 ===');
      print('currentUserId: $currentUserId');
      print('targetPetId: $targetPetId');

      // 1. 타겟 펫 정보 조회
      var petResponse =
          await SupabaseService.client
              .from('pets')
              .select('id, name, owner_id')
              .eq('id', targetPetId)
              .single();

      String targetPetOwnerId = petResponse['owner_id'];
      String targetPetName = petResponse['name'];

      print('타겟 펫 주인: $targetPetOwnerId');
      print('타겟 펫 이름: $targetPetName');

      // 2. 자기 자신의 펫인지 확인
      if (targetPetOwnerId == currentUserId) {
        throw Exception('자신의 펫과는 채팅할 수 없습니다');
      }

      // 3. 현재 사용자의 펫 정보 조회
      var myPetResponse = await SupabaseService.client
          .from('pets')
          .select('id, name')
          .eq('owner_id', currentUserId)
          .order('created_at', ascending: false)
          .limit(1);

      if (myPetResponse.isEmpty) {
        throw Exception('등록된 펫이 없습니다. 먼저 펫을 등록해주세요.');
      }

      int myPetId = myPetResponse.first['id'];
      String myPetName = myPetResponse.first['name'];

      print('내 펫 ID: $myPetId');
      print('내 펫 이름: $myPetName');

      // 4. 특정 펫들 간의 기존 채팅방 확인 (펫 ID 기준)
      print('기존 채팅방 검색 중... (내 펫: $myPetId, 상대 펫: $targetPetId)');

      // 방향 1: 내 펫이 pet1, 상대 펫이 pet2
      var existingRoom1 = await SupabaseService.client
          .from('chat_rooms_with_users')
          .select('*')
          .eq('pet1_id', myPetId)
          .eq('pet2_id', targetPetId)
          .eq('is_active', true)
          .limit(1);

      if (existingRoom1.isNotEmpty) {
        print('기존 채팅방 발견 (방향1): ${existingRoom1.first['id']}');
        return ChatRoom.fromJson(existingRoom1.first);
      }

      // 방향 2: 상대 펫이 pet1, 내 펫이 pet2
      var existingRoom2 = await SupabaseService.client
          .from('chat_rooms_with_users')
          .select('*')
          .eq('pet1_id', targetPetId)
          .eq('pet2_id', myPetId)
          .eq('is_active', true)
          .limit(1);

      if (existingRoom2.isNotEmpty) {
        print('기존 채팅방 발견 (방향2): ${existingRoom2.first['id']}');
        return ChatRoom.fromJson(existingRoom2.first);
      }

      print('기존 채팅방이 없음. 새 채팅방 생성');
      print('생성할 채팅방: 내 펫($myPetId) <-> 상대 펫($targetPetId)');

      // 5. 새 채팅방 생성
      var newChatRoomResponse =
          await SupabaseService.client
              .from('chat_rooms')
              .insert({
                'user1_id': currentUserId,
                'user2_id': targetPetOwnerId,
                'pet1_id': myPetId,
                'pet2_id': targetPetId,
                'chat_type': 'pet_chat',
                'is_active': true,
              })
              .select()
              .single();

      print('채팅방 생성 완료: ${newChatRoomResponse['id']}');

      // 6. 생성된 채팅방을 뷰에서 다시 조회
      var chatRoomWithUsersResponse =
          await SupabaseService.client
              .from('chat_rooms_with_users')
              .select('*')
              .eq('id', newChatRoomResponse['id'])
              .single();

      print('최종 채팅방 정보:');
      print('  - 채팅방 ID: ${chatRoomWithUsersResponse['id']}');
      print('  - pet1_id: ${chatRoomWithUsersResponse['pet1_id']}');
      print('  - pet2_id: ${chatRoomWithUsersResponse['pet2_id']}');
      print('  - pet1_name: ${chatRoomWithUsersResponse['pet1_name']}');
      print('  - pet2_name: ${chatRoomWithUsersResponse['pet2_name']}');

      return ChatRoom.fromJson(chatRoomWithUsersResponse);
    } catch (e) {
      print('findOrCreatePetChatRoom 에러: $e');
      rethrow;
    }
  }

  static Future<List<ChatMessage>> getChatMessages(int chatRoomId) async {
    try {
      var response = await SupabaseService.client
          .from('chat_messages')
          .select()
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: true);

      return response
          .map<ChatMessage>((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (error) {
      return [];
    }
  }

  static Future<ChatMessage?> sendMessage({
    required int chatRoomId,
    required String senderId,
    required String message,
    String messageType = 'text',
  }) async {
    try {
      // 메시지 생성 - DB 스키마에 맞게 'content' 필드 사용
      var response =
          await SupabaseService.client
              .from('chat_messages')
              .insert({
                'chat_room_id': chatRoomId,
                'sender_id': senderId,
                'content': message, // 'message'가 아닌 'content' 사용
                'message_type': messageType,
              })
              .select()
              .single();

      // 채팅방 마지막 메시지 업데이트
      await SupabaseService.client
          .from('chat_rooms')
          .update({
            'last_message': message,
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .eq('id', chatRoomId);

      return ChatMessage.fromJson(response);
    } catch (error) {
      return null;
    }
  }

  static Future<bool> markMessagesAsRead({
    required int chatRoomId,
    required String userId,
  }) async {
    try {
      await SupabaseService.client
          .from('chat_messages')
          .update({'is_read': true})
          .eq('chat_room_id', chatRoomId)
          .neq('sender_id', userId)
          .eq('is_read', false);

      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<int> getUnreadMessageCount(String userId) async {
    try {
      // 사용자가 참여한 채팅방들 조회
      var chatRoomsResponse = await SupabaseService.client
          .from('chat_rooms')
          .select('id')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .eq('is_active', true);

      var chatRoomIds =
          chatRoomsResponse.map<int>((room) => room['id'] as int).toList();

      if (chatRoomIds.isEmpty) return 0;

      // 읽지 않은 메시지들을 조회해서 개수를 직접 계산
      var unreadResponse = await SupabaseService.client
          .from('chat_messages')
          .select('id')
          .inFilter('chat_room_id', chatRoomIds)
          .neq('sender_id', userId)
          .eq('is_read', false);

      return unreadResponse.length;
    } catch (error) {
      return 0;
    }
  }

  static Future<bool> deleteChatRoom(int chatRoomId) async {
    try {
      await SupabaseService.client
          .from('chat_rooms')
          .update({'is_active': false})
          .eq('id', chatRoomId);

      return true;
    } catch (error) {
      return false;
    }
  }
}
