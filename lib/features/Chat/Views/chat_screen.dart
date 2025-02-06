import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../../Core/presentation/resources/app_colors.dart';
import '../../../Providers/chat_provider.dart';
import '../../../Providers/user_manager_provider.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId =
          context.read<UserManagerProvider>().userInfo?.id.toString();
      if (userId != null) {
        final chatProvider = context.read<ChatProvider>();
        await chatProvider.initialize(userId);
        await chatProvider.initializeChat(widget.otherUserId);
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.messageScrollController.hasClients) {
      chatProvider.messageScrollController.animateTo(
        chatProvider.messageScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(ChatProvider chatProvider) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      chatProvider.sendMessage(message, widget.otherUserId);
      _messageController.clear();
      _focusNode.requestFocus();

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        return WillPopScope(
          onWillPop: () async {
            chatProvider.leaveChat();
            return true;
          },
          child: Scaffold(
            appBar: _buildAppBar(chatProvider),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.error != null
                        ? _buildErrorState(chatProvider.error!)
                        : _buildMessageList(chatProvider),
                  ),
                  _buildMessageInput(chatProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageList(ChatProvider chatProvider) {
    if (chatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatProvider.messages.isEmpty) {
      return const Center(child: Text('No messages yet'));
    }

    return ListView.builder(
      controller: chatProvider.messageScrollController,
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(16),
        vertical: context.getHeight(16),
      ),
      itemCount: chatProvider.messages.length,
      reverse: true, // Make messages start from bottom
      itemBuilder: (context, index) {
        // Reverse index to show messages in correct order
        final message =
            chatProvider.messages[chatProvider.messages.length - 1 - index];
        final isMe = message.userId == chatProvider.currentUserId;
        return _MessageBubble(
          message: message.message,
          isMe: isMe,
          timestamp: message.timestamp,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ChatProvider chatProvider) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          chatProvider.leaveChat();
          Navigator.pop(context);
        },
      ),
      titleSpacing: 0,
      title: _buildUserInfo(chatProvider),
    );
  }

  Widget _buildUserInfo(ChatProvider chatProvider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.otherUserName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                chatProvider.isConnected ? 'online' : 'offline',
                style: TextStyle(
                  fontSize: 12,
                  color: chatProvider.isConnected
                      ? Colors.green[400]
                      : Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(ChatProvider chatProvider) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(8)),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              enabled: !chatProvider.isLoading && chatProvider.isConnected,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onSubmitted: (_) => _sendMessage(chatProvider),
              decoration: InputDecoration(
                hintText: chatProvider.isConnected
                    ? 'Type a message...'
                    : 'Connecting...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(16),
                  vertical: context.getHeight(8),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: AppColors.primaryColor,
            onPressed: chatProvider.isConnected
                ? () => _sendMessage(chatProvider)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeChat,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime timestamp;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMe ? 64 : 0,
        right: isMe ? 0 : 64,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: isMe ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  color: isMe ? Colors.white70 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
