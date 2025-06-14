import 'package:udangtan_flutter_app/models/chat_message.dart';
import 'package:udangtan_flutter_app/models/chat_room.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  static RealtimeChannel? subscribeToMessages(
    int chatRoomId,
    Function(ChatMessage) onNewMessage,
  ) {
    try {
      final channel =
          SupabaseService.client
              .channel('chat_messages_$chatRoomId')
              .onPostgresChanges(
                event: PostgresChangeEvent.insert,
                schema: 'public',
                table: 'chat_messages',
                filter: PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'chat_room_id',
                  value: chatRoomId,
                ),
                callback: (payload) {
                  try {
                    final newMessage = ChatMessage.fromJson(payload.newRecord);
                    onNewMessage(newMessage);
                  } catch (e) {
                    print('새 메시지 파싱 오류: $e');
                  }
                },
              )
              .subscribe();

      return channel;
    } catch (e) {
      print('실시간 구독 오류: $e');
      return null;
    }
  }

  // 구독 해제
  static Future<void> unsubscribeFromMessages(RealtimeChannel? channel) async {
    if (channel != null) {
      await SupabaseService.client.removeChannel(channel);
    }
  }

  static Future<List<ChatRoom>> getChatRooms(String userId) async {
    try {
      var response = await SupabaseService.client
          .from('chat_rooms_with_users')
          .select('*')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .eq('is_active', true)
          .order('last_message_at', ascending: false);

      var chatRooms =
          response.map<ChatRoom>((json) => ChatRoom.fromJson(json)).toList();

      return chatRooms;
    } catch (error) {
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
      // 타겟 펫 정보 조회
      var petResponse =
          await SupabaseService.client
              .from('pets')
              .select('id, name, owner_id')
              .eq('id', targetPetId)
              .single();

      String targetPetOwnerId = petResponse['owner_id'];
      // String targetPetName = petResponse['name'];

      // 자기 자신의 펫인지 확인
      if (targetPetOwnerId == currentUserId) {
        throw Exception('자신의 펫과는 채팅할 수 없습니다');
      }

      // 현재 사용자의 펫 정보 조회
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
      // String myPetName = myPetResponse.first['name'];

      var existingRoom1 = await SupabaseService.client
          .from('chat_rooms_with_users')
          .select('*')
          .eq('pet1_id', myPetId)
          .eq('pet2_id', targetPetId)
          .eq('is_active', true)
          .limit(1);

      if (existingRoom1.isNotEmpty) {
        return ChatRoom.fromJson(existingRoom1.first);
      }

      // 상대 펫이 pet1, 내 펫이 pet2
      var existingRoom2 = await SupabaseService.client
          .from('chat_rooms_with_users')
          .select('*')
          .eq('pet1_id', targetPetId)
          .eq('pet2_id', myPetId)
          .eq('is_active', true)
          .limit(1);

      if (existingRoom2.isNotEmpty) {
        return ChatRoom.fromJson(existingRoom2.first);
      }

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

      // 생성된 채팅방을 뷰에서 다시 조회
      var chatRoomWithUsersResponse =
          await SupabaseService.client
              .from('chat_rooms_with_users')
              .select('*')
              .eq('id', newChatRoomResponse['id'])
              .single();

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
      var response =
          await SupabaseService.client
              .from('chat_messages')
              .insert({
                'chat_room_id': chatRoomId,
                'sender_id': senderId,
                'content': message,
                'message_type': messageType,
                'is_read': false,
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
      print('메시지 전송 오류: $error');
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

  static Future<int> getUnreadMessageCountForChatRoom({
    required int chatRoomId,
    required String userId,
  }) async {
    try {
      var unreadResponse = await SupabaseService.client
          .from('chat_messages')
          .select('id')
          .eq('chat_room_id', chatRoomId)
          .neq('sender_id', userId)
          .eq('is_read', false);

      return unreadResponse.length;
    } catch (error) {
      print('채팅방별 읽지 않은 메시지 개수 조회 오류: $error');
      return 0;
    }
  }

  static Future<Map<int, int>> getUnreadCountsForAllChatRooms(
    String userId,
  ) async {
    try {
      // 사용자가 참여한 채팅방들 조회
      var chatRoomsResponse = await SupabaseService.client
          .from('chat_rooms')
          .select('id')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .eq('is_active', true);

      var chatRoomIds =
          chatRoomsResponse.map<int>((room) => room['id'] as int).toList();

      if (chatRoomIds.isEmpty) return {};

      Map<int, int> unreadCounts = {};

      // 각 채팅방별로 읽지 않은 메시지 개수 조회
      for (int chatRoomId in chatRoomIds) {
        var count = await getUnreadMessageCountForChatRoom(
          chatRoomId: chatRoomId,
          userId: userId,
        );
        unreadCounts[chatRoomId] = count;
      }

      return unreadCounts;
    } catch (error) {
      print('전체 채팅방 읽지 않은 메시지 개수 조회 오류: $error');
      return {};
    }
  }
}
