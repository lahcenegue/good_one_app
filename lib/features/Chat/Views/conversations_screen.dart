import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Widgets/error/error_widget.dart';
import 'package:good_one_app/Core/presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Features/Chat/Models/chat_conversation.dart';
import 'package:good_one_app/Features/Chat/Views/chat_screen.dart';
import 'package:good_one_app/Features/Chat/Widgets/chat_utils.dart';
import 'package:good_one_app/Providers/chat_provider.dart';
import 'package:good_one_app/Providers/user_manager_provider.dart';
import 'package:provider/provider.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final userId = context.read<UserManagerProvider>().userInfo?.id.toString();
    if (userId != null) {
      await context.read<ChatProvider>().initialize(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Messages',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          // Show loading until initial fetch is complete or if explicitly loading
          if (!provider.initialFetchComplete ||
              provider.isLoadingConversations) {
            return const LoadingIndicator(message: 'Loading conversations...');
          }
          if (provider.error != null) {
            return AppErrorWidget.custom(
              message: provider.error!,
              onRetry: provider.initializeConversations,
            );
          }
          if (provider.conversations.isEmpty) {
            return const _EmptyState();
          }
          return RefreshIndicator(
            onRefresh: provider.initializeConversations,
            child: ListView.separated(
              itemCount: provider.conversations.length,
              separatorBuilder: (_, __) =>
                  const Divider(indent: 20, endIndent: 20),
              itemBuilder: (_, index) => _ConversationTile(
                conversation: provider.conversations[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              otherUserId: conversation.user.id.toString(),
              otherUserName: conversation.user.fullName,
            ),
          ),
        );
      },
      leading: UserAvatar(
          picture: conversation.user.picture, size: context.getWidth(60)),
      title: Text(conversation.user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        conversation.latestMessage ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(ChatUtils.formatMessageTime(conversation.time)),
          if (conversation.hasNewMessages)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('NEW',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: context.getAdaptiveSize(64), color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No conversations yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Text('Start a new conversation',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
