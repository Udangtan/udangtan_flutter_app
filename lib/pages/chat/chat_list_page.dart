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
  Map<int, int> _unreadCounts = {};
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
        var unreadCounts = await ChatService.getUnreadCountsForAllChatRooms(
          user.id,
        );

        setState(() {
          _chatRooms = chatRooms;
          _unreadCounts = unreadCounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('채팅방 로드 실패: $e');
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            '아직 채팅방이 없어요',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            '간식함에서 펫을 클릭하여 채팅을 시작해보세요!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 간식함 페이지로 이동
              widget.onNavTap(1); // 간식함이 인덱스 1이라고 가정
            },
            child: const Text('간식함으로 가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomCard(ChatRoom chatRoom) {
    var currentUserId = SupabaseService.client.auth.currentUser?.id ?? '';
    var unreadCount = _unreadCounts[chatRoom.id] ?? 0;

    var otherUserName = chatRoom.getOtherUserName(currentUserId);
    var otherPetName = chatRoom.getOtherPetName(currentUserId);
    var otherUserProfileImage = chatRoom.getOtherUserProfileImage(
      currentUserId,
    );

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(chatRoom: chatRoom),
          ),
        );
        await _loadChatRooms();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            _buildProfileImage(otherUserProfileImage),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              otherPetName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '주인: $otherUserName',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (chatRoom.lastMessageAt != null)
                  Text(
                    _formatLastMessageTime(chatRoom.lastMessageAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                const SizedBox(height: 6),
                if (unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? profileImageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        color: Colors.grey[200],
        child:
            profileImageUrl != null &&
                    profileImageUrl.isNotEmpty &&
                    (profileImageUrl.startsWith('http://') ||
                        profileImageUrl.startsWith('https://'))
                ? Image.network(
                  profileImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.pets, size: 30, color: Colors.grey),
                )
                : const Icon(Icons.pets, size: 30, color: Colors.grey),
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
