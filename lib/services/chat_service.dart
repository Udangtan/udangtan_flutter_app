import 'package:udangtan_flutter_app/models/chat_message.dart';
import 'package:udangtan_flutter_app/models/chat_room.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';

class ChatService {
  static Future<List<ChatRoom>> getChatRooms(String userId) async {
    try {
      var response = await SupabaseService.client
          .from('chat_rooms_with_users')
          .select()
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .eq('is_active', true)
          .order('last_message_at', ascending: false);

      return response.map<ChatRoom>((json) => ChatRoom.fromJson(json)).toList();
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
      // 메시지 생성
      var response =
          await SupabaseService.client
              .from('chat_messages')
              .insert({
                'chat_room_id': chatRoomId,
                'sender_id': senderId,
                'message': message,
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
