import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/error/error_widget.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/Chat/Models/chat_message.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen(
      {super.key, required this.otherUserId, required this.otherUserName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final provider = context.read<ChatProvider>();
    final userId = context.read<UserManagerProvider>().userInfo?.id.toString();
    if (userId != null && !provider.isConnected) {
      await provider.initialize(userId);
    }
    await provider.initializeChat(widget.otherUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () {
                Navigator.pop(context);
              }),
              title: Text(widget.otherUserName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              titleSpacing: 0,
            ),
            body: Column(
              children: [
                Expanded(
                  child: provider.isLoadingMessages
                      ? const LoadingIndicator()
                      : provider.error != null
                          ? AppErrorWidget.custom(
                              message: provider.error!, onRetry: _initialize)
                          : provider.messages.isEmpty
                              ? const _EmptyMessages()
                              : _MessageList(provider: provider),
                ),
                _MessageInput(controller: _controller, focusNode: _focusNode),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _MessageList extends StatelessWidget {
  final ChatProvider provider;

  const _MessageList({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: provider.scrollController,
      reverse: true,
      padding: EdgeInsets.all(context.getWidth(16)),
      itemCount: provider.messages.length,
      itemBuilder: (_, index) {
        final message = provider.messages[provider.messages.length - 1 - index];
        return _MessageBubble(
          message: message,
          isMe: message.userId == provider.currentUserId,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: context.getWidth(300)),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primaryColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.message,
                  style:
                      TextStyle(color: isMe ? Colors.white : Colors.black87)),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _MessageInput({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    return Padding(
      padding: EdgeInsets.all(context.getWidth(8)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: provider.isConnected,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.typeMessage,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: AppColors.primaryColor,
            onPressed: provider.isConnected
                ? () {
                    provider.sendMessage(
                        controller.text, provider.currentChatUserId!);
                    controller.clear();
                    focusNode.requestFocus();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.noMessagesYet));
  }
}
