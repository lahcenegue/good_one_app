import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Core/Presentation/Widgets/error/error_widget.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/Chat/Models/chat_conversation.dart';
import 'package:good_one_app/Features/Chat/Presentation/Screens/chat_screen.dart';
import 'package:good_one_app/Features/Chat/Presentation/Utils/chat_utils.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final type = await StorageManager.getString(StorageKeys.accountTypeKey);
    if (type == AppConfig.user) {
      final userId =
          context.read<UserManagerProvider>().userInfo?.id.toString();
      if (userId != null) {
        await context.read<ChatProvider>().initialize(userId);
      }
    } else {
      final workerId =
          context.read<WorkerManagerProvider>().workerInfo?.id.toString();
      if (workerId != null) {
        await context.read<ChatProvider>().initialize(workerId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(AppLocalizations.of(context)!.messages,
            style: AppTextStyles.appBarTitle(context)),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (!provider.initialFetchComplete ||
              provider.isLoadingConversations) {
            return const LoadingIndicator();
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
        conversation.latestMessage ??
            AppLocalizations.of(context)!.noMessagesYet,
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
              child: Text(AppLocalizations.of(context)!.newMessage,
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
          Text(AppLocalizations.of(context)!.noConversations,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(AppLocalizations.of(context)!.startNewConversation,
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
