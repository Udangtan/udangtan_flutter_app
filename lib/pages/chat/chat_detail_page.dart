import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udangtan_flutter_app/models/chat_message.dart';
import 'package:udangtan_flutter_app/models/chat_room.dart';
import 'package:udangtan_flutter_app/services/chat_service.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key, required this.chatRoom});

  final ChatRoom chatRoom;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();
  RealtimeChannel? _messageSubscription;

  List<ChatMessage> _messages = [];
  bool _isKeyboardVisible = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCurrentUser();
    _loadMessages();
    _subscribeToMessages();

    _textFieldFocusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _subscribeToMessages() {
    if (widget.chatRoom.id != null) {
      _messageSubscription = ChatService.subscribeToMessages(
        widget.chatRoom.id!,
        (newMessage) {
          // 자신이 보낸 메시지가 아닐 때만 추가 (중복 방지)
          if (newMessage.senderId != _currentUserId) {
            setState(() {
              _messages.add(newMessage);
            });
            _scrollToBottomWithDelay();

            // 메시지를 읽음으로 표시
            if (_currentUserId != null) {
              ChatService.markMessagesAsRead(
                chatRoomId: widget.chatRoom.id!,
                userId: _currentUserId!,
              );
            }
          }
        },
      );
    }
  }

  Future<void> _initializeCurrentUser() async {
    var user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.id;
      });

      // 메시지를 읽음으로 표시
      if (widget.chatRoom.id != null) {
        await ChatService.markMessagesAsRead(
          chatRoomId: widget.chatRoom.id!,
          userId: user.id,
        );
      }
    }
  }

  Future<void> _loadMessages() async {
    try {
      if (widget.chatRoom.id != null) {
        var messages = await ChatService.getChatMessages(widget.chatRoom.id!);
        setState(() {
          _messages = messages;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    ChatService.unsubscribeFromMessages(_messageSubscription);

    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.removeListener(_onFocusChange);
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    var bottomInset = View.of(context).viewInsets.bottom;
    var newKeyboardVisible = bottomInset > 0;

    if (newKeyboardVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newKeyboardVisible;
      });

      if (newKeyboardVisible) {
        _scrollToBottomWithDelay();
      }
    }
  }

  void _onFocusChange() {
    if (_textFieldFocusNode.hasFocus) {
      _scrollToBottomWithDelay();
    }
  }

  Future<void> _sendMessage(String messageText) async {
    if (messageText.trim().isEmpty ||
        _currentUserId == null ||
        widget.chatRoom.id == null) {
      return;
    }

    try {
      var sentMessage = await ChatService.sendMessage(
        chatRoomId: widget.chatRoom.id!,
        senderId: _currentUserId!,
        message: messageText,
      );

      if (sentMessage != null) {
        setState(() {
          _messages.add(sentMessage);
          _messageController.clear();
        });

        _scrollToBottomWithDelay();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('메시지 전송 실패: $e')));
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottomWithDelay() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isSameMinute(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  // 상대방 펫 이름 가져오기 (타이틀용)
  String _getOtherPetName() {
    if (_currentUserId == null) return '채팅';
    return widget.chatRoom.getOtherPetName(_currentUserId!);
  }

  // 상대방 사용자 프로필 이미지 (아바타용)
  String? _getOtherUserProfileImage() {
    if (_currentUserId == null) return null;
    return widget.chatRoom.getOtherUserProfileImage(_currentUserId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      resizeToAvoidBottomInset: true,
      appBar: CommonAppBar(
        title: _getOtherPetName(),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'profile', child: Text('프로필 보기')),
                  const PopupMenuItem(value: 'block', child: Text('차단하기')),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var message = _messages[index];
                ChatMessage? prevMessage =
                    index > 0 ? _messages[index - 1] : null;

                bool showTime = true;
                if (index < _messages.length - 1) {
                  var next = _messages[index + 1];
                  var sameMinute = _isSameMinute(
                    message.createdAt,
                    next.createdAt,
                  );
                  if (sameMinute && message.senderId == next.senderId) {
                    showTime = false;
                  }
                }

                return _buildMessageBubble(message, showTime, prevMessage);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage message,
    bool showTime,
    ChatMessage? previousMessage,
  ) {
    var isFromMe = message.senderId == _currentUserId;

    var shouldShowAvatar =
        !isFromMe &&
        (previousMessage == null ||
            previousMessage.senderId != message.senderId ||
            !_isSameMinute(previousMessage.createdAt, message.createdAt));

    if (isFromMe) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTime && message.createdAt != null) ...[
              Text(
                _formatTime(message.createdAt!),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(2),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message.content, // 단순히 content만 사용
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: shouldShowAvatar ? 6 : 2,
          horizontal: 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shouldShowAvatar) ...[
              _buildUserAvatar(),
              const SizedBox(width: 8),
            ] else ...[
              const SizedBox(width: 44),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (shouldShowAvatar) ...[
                  Text(
                    _getOtherPetName(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(2),
                            topRight: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          message.content, // 단순히 content만 사용
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    if (showTime && message.createdAt != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(message.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildUserAvatar() {
    String? profileImageUrl = _getOtherUserProfileImage();

    if (profileImageUrl != null &&
        profileImageUrl.isNotEmpty &&
        (profileImageUrl.startsWith('http://') ||
            profileImageUrl.startsWith('https://'))) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(profileImageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle error silently
        },
      );
    } else {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade300,
        child: const Icon(Icons.pets, size: 16, color: Colors.grey),
      );
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.grey, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _textFieldFocusNode,
                  decoration: const InputDecoration(
                    hintText: '메시지를 입력하세요',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) => _sendMessage(value),
                  onTap: () => _scrollToBottomWithDelay(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
