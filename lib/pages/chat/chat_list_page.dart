import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/models/chat_room.dart';
import 'package:udangtan_flutter_app/pages/chat/chat_detail_page.dart';
import 'package:udangtan_flutter_app/services/chat_service.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({
    super.key,
    required this.currentNavIndex,
    required this.onNavTap,
  });

  final int currentNavIndex;
  final Function(int) onNavTap;

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    try {
      var user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        var chatRooms = await ChatService.getChatRooms(user.id);
        setState(() {
          _chatRooms = chatRooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CommonAppBar(title: '채팅', automaticallyImplyLeading: false),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                ),
              )
              : _chatRooms.isEmpty
              ? _getEmptyState()
              : RefreshIndicator(
                onRefresh: _loadChatRooms,
                child: ListView.separated(
                  itemCount: _chatRooms.length,
                  separatorBuilder:
                      (context, index) =>
                          Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    return _buildChatRoomCard(_chatRooms[index]);
                  },
                ),
              ),
    );
  }

  Widget _getEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '아직 채팅방이 없어요',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            '펫을 찜하고 새로운 친구를 만나보세요!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomCard(ChatRoom chatRoom) {
    var currentUserId = SupabaseService.client.auth.currentUser?.id ?? '';

    var otherUserName = chatRoom.getOtherUserName(currentUserId);
    var otherUserProfileImage = chatRoom.getOtherUserProfileImage(
      currentUserId,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(chatRoom: chatRoom),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child:
                    otherUserProfileImage != null
                        ? Image.network(
                          otherUserProfileImage,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey,
                              ),
                        )
                        : const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        otherUserName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (chatRoom.lastMessageAt != null)
                        Text(
                          _formatLastMessageTime(chatRoom.lastMessageAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chatRoom.lastMessage ?? '메시지가 없습니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastMessageTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    var now = DateTime.now();
    var difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
