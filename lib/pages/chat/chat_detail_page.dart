import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/models/chat_message.dart';
import 'package:udangtan_flutter_app/models/chat_room.dart';
import 'package:udangtan_flutter_app/services/chat_service.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';
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

  List<ChatMessage> _messages = [];
  bool _isKeyboardVisible = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCurrentUser();
    _loadMessages();

    _textFieldFocusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _initializeCurrentUser() async {
    var user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.id;
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      if (widget.chatRoom.id != null) {
        var messages = await ChatService.getChatMessages(widget.chatRoom.id!);
        setState(() {
          _messages = messages;
        });
      }
    } catch (e) {
      // 에러 처리
    }
  }

  @override
  void dispose() {
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

      // 키보드가 올라올 때 스크롤
      if (newKeyboardVisible) {
        _scrollToBottomWithDelay();
      }
    }
  }

  // 텍스트 필드 포커스 변화 감지
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
      await ChatService.sendMessage(
        chatRoomId: widget.chatRoom.id!,
        senderId: _currentUserId!,
        message: messageText,
      );

      setState(() {
        _messageController.clear();
      });

      // 메시지 목록 새로고침
      await _loadMessages();
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
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
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

  String _getOtherUserName() {
    if (_currentUserId == widget.chatRoom.user1Id) {
      return widget.chatRoom.user2Name ?? 'Unknown';
    } else {
      return widget.chatRoom.user1Name ?? 'Unknown';
    }
  }

  String? _getOtherUserProfileImage() {
    if (_currentUserId == widget.chatRoom.user1Id) {
      return widget.chatRoom.user2ProfileImage;
    } else {
      return widget.chatRoom.user1ProfileImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      resizeToAvoidBottomInset: true,
      appBar: CommonAppBar(
        title: _getOtherUserName(),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Text('${_getOtherUserName()} 프로필'),
                  ),
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
                  if (sameMinute) {
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
                  color: Color(0xFFE1BEE7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(2),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message.message,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
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
          horizontal: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shouldShowAvatar) ...[
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    _getOtherUserProfileImage() != null
                        ? NetworkImage(_getOtherUserProfileImage()!)
                        : null,
                child:
                    _getOtherUserProfileImage() == null
                        ? const Icon(Icons.person, size: 16)
                        : null,
              ),
              const SizedBox(width: 8),
            ] else ...[
              const SizedBox(width: 44),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (shouldShowAvatar) ...[
                  Text(
                    _getOtherUserName(),
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
                          message.message,
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
                    hintText: '메시지를 입력하세요...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) => _sendMessage(value),
                  onTap: () => _scrollToBottomWithDelay(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sentiment_satisfied_alt,
                color: Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tag, color: Colors.grey, size: 20),
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
