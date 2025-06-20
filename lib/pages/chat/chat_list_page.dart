import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udangtan_flutter_app/models/chat_room.dart';
import 'package:udangtan_flutter_app/pages/chat/chat_detail_page.dart';
import 'package:udangtan_flutter_app/services/chat_service.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
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

class _ChatListPageState extends State<ChatListPage>
    with WidgetsBindingObserver {
  List<ChatRoom> _chatRooms = [];
  Map<int, int> _unreadCounts = {};
  bool _isLoading = true;
  int _lastNavIndex = -1;

  // Realtime subscription
  RealtimeChannel? _chatUpdatesChannel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastNavIndex = widget.currentNavIndex;
    _loadChatRooms();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ChatService.unsubscribeFromMessages(_chatUpdatesChannel);
    super.dispose();
  }

  void _setupRealtimeListener() {
    final currentUserId = SupabaseService.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    _chatUpdatesChannel = ChatService.subscribeToAllChatUpdates(
      currentUserId,
      onNewMessage: _handleNewMessage,
      onMessageUpdate: _handleMessageUpdate,
      onChatRoomUpdate: _handleChatRoomUpdate,
    );
  }

  Future<void> _handleNewMessage(Map<String, dynamic> messageData) async {
    final currentUserId = SupabaseService.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    final chatRoomId = messageData['chat_room_id'] as int?;
    final senderId = messageData['sender_id'] as String?;

    if (chatRoomId != null) {
      // 해당 채팅방이 현재 사용자와 관련있는지 확인
      final isRelated = await ChatService.isChatRoomRelatedToUser(
        chatRoomId,
        currentUserId,
      );

      if (isRelated) {
        // 내가 보낸 메시지가 아닌 경우에만 읽지 않은 메시지 수 증가
        if (senderId != currentUserId) {
          setState(() {
            _unreadCounts[chatRoomId] = (_unreadCounts[chatRoomId] ?? 0) + 1;
          });
        }

        // 채팅방 목록 순서 업데이트
        await _updateChatRoomOrder();
      }
    }
  }

  Future<void> _handleMessageUpdate(Map<String, dynamic> messageData) async {
    final currentUserId = SupabaseService.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    final chatRoomId = messageData['chat_room_id'] as int?;

    if (chatRoomId != null) {
      // 읽지 않은 메시지 수 다시 계산
      await _updateUnreadCount(chatRoomId);
    }
  }

  Future<void> _handleChatRoomUpdate(Map<String, dynamic> chatRoomData) async {
    final chatRoomId = chatRoomData['id'] as int?;

    if (chatRoomId != null) {
      await _updateChatRoomOrder();
    }
  }

  Future<void> _updateUnreadCount(int chatRoomId) async {
    try {
      final currentUserId = SupabaseService.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final unreadCount = await ChatService.getUnreadCount(
        chatRoomId,
        currentUserId,
      );

      setState(() {
        _unreadCounts[chatRoomId] = unreadCount;
      });
    } catch (e) {
      print('읽지 않은 메시지 수 업데이트 실패: $e');
    }
  }

  Future<void> _updateChatRoomOrder() async {
    try {
      final currentUserId = SupabaseService.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final updatedChatRooms = await ChatService.getChatRooms(currentUserId);

      setState(() {
        _chatRooms = updatedChatRooms;
      });
    } catch (e) {
      print('채팅방 순서 업데이트 실패: $e');
    }
  }

  @override
  void didUpdateWidget(ChatListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 채팅 탭(인덱스 3)으로 변경되었을 때 자동 갱신
    if (oldWidget.currentNavIndex != widget.currentNavIndex &&
        widget.currentNavIndex == 3 &&
        _lastNavIndex != 3) {
      _loadChatRooms();
    }
    _lastNavIndex = widget.currentNavIndex;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && widget.currentNavIndex == 3) {
      _loadChatRooms();
    }
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
          GestureDetector(
            onTap: () {
              // 간식함 페이지로 이동
              widget.onNavTap(1); // 간식함이 인덱스 1이라고 가정
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '간식함으로 가기',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomCard(ChatRoom chatRoom) {
    var currentUserId = SupabaseService.client.auth.currentUser?.id ?? '';
    var unreadCount = _unreadCounts[chatRoom.id] ?? 0;

    // var otherUserName = chatRoom.getOtherUserName(currentUserId);
    var otherPetName = chatRoom.getOtherPetName(currentUserId);
    var myPetName = chatRoom.getMyPetName(currentUserId);
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
                              '내 펫: $myPetName',
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
