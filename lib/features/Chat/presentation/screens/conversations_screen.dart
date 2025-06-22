import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/user_helper.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/Chat/Models/chat_conversation.dart';
import 'package:good_one_app/Features/Chat/Presentation/Screens/chat_screen.dart';
import 'package:good_one_app/Features/Chat/Presentation/Utils/chat_utils.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  bool _isInitialized = false;
  String? _accountType;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      _accountType = await StorageManager.getString(StorageKeys.accountTypeKey);
      debugPrint(
          'ConversationsScreen: Account type from storage: $_accountType');

      // Get user ID using the helper utility with better error handling
      final userId = UserHelper.getCurrentUserId(context);

      if (userId != null && userId.isNotEmpty) {
        debugPrint(
            'ConversationsScreen: Initializing chat for user ID: $userId');
        await context.read<ChatProvider>().initialize(userId);
        setState(() => _isInitialized = true);
        debugPrint('ConversationsScreen: Successfully initialized');
      } else {
        throw Exception('User ID not available - user may not be logged in');
      }
    } catch (e) {
      debugPrint('ConversationsScreen: Initialization error: $e');
      // Set a more specific error message
      context
          .read<ChatProvider>()
          .setError(AppLocalizations.of(context)!.failedToInitializeChat);
    } finally {
      _isInitializing = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _refresh() async {
    final provider = context.read<ChatProvider>();

    if (!provider.isConnected) {
      // Try to reconnect if disconnected
      await _initialize();
    } else {
      // Just refresh conversations using the correct method name
      await provider.initializeConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          AppLocalizations.of(context)!.messages,
          style: AppTextStyles.appBarTitle(context),
        ),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: Icon(
                  provider.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: provider.isConnected ? Colors.green : Colors.red,
                ),
                onPressed: provider.isConnected ? null : _refresh,
                tooltip: provider.isConnected
                    ? AppLocalizations.of(context)!.connected
                    : AppLocalizations.of(context)!.reconnect,
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (!_isInitialized && _isInitializing) {
            return const _InitializingState();
          }

          if (!provider.initialFetchComplete ||
              provider.isLoadingConversations) {
            return const _LoadingState();
          }

          if (provider.error != null) {
            return _ErrorState(
              error: provider.error!,
              onRetry: _refresh,
              isConnected: provider.isConnected,
            );
          }

          if (provider.conversations.isEmpty) {
            return _EmptyState(
              onRefresh: _refresh,
              isConnected: provider.isConnected,
            );
          }

          // Sort conversations: unread messages first, then by time
          final sortedConversations =
              List<ChatConversation>.from(provider.conversations);
          sortedConversations.sort((a, b) {
            // First, prioritize conversations with new messages
            if (a.hasNewMessages && !b.hasNewMessages) return -1;
            if (!a.hasNewMessages && b.hasNewMessages) return 1;

            // If both have the same new message status, sort by time (most recent first)
            return (b.time ?? '').compareTo(a.time ?? '');
          });

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sortedConversations.length,
              separatorBuilder: (_, __) => const Divider(
                indent: 72,
                endIndent: 16,
                height: 1,
              ),
              itemBuilder: (_, index) => _ConversationTile(
                conversation: sortedConversations[index],
                accountType: _accountType,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InitializingState extends StatelessWidget {
  const _InitializingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(),
          SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.initializingChat),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(),
          SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.loadingConversations),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isConnected;

  const _ErrorState({
    required this.error,
    required this.onRetry,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnected ? Icons.error_outline : Icons.wifi_off,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isConnected) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.checkConnection,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(isConnected ? Icons.refresh : Icons.wifi),
              label: Text(
                isConnected
                    ? AppLocalizations.of(context)!.retry
                    : AppLocalizations.of(context)!.reconnect,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final String? accountType;

  const _ConversationTile({
    required this.conversation,
    this.accountType,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _navigateToChat(context),
      leading: Stack(
        children: [
          UserAvatar(
            picture: conversation.user.picture,
            size: context.getWidth(56),
          ),
          // Add a visual indicator for unread messages on the avatar
          if (conversation.hasNewMessages)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conversation.user.fullName.isNotEmpty
            ? conversation.user.fullName
            : AppLocalizations.of(context)!.unknownUser,
        style: TextStyle(
          fontWeight:
              conversation.hasNewMessages ? FontWeight.w700 : FontWeight.w600,
          fontSize: 16,
          color: conversation.hasNewMessages ? Colors.black : Colors.black87,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: _buildSubtitle(context),
      trailing: _buildTrailing(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Add subtle background highlight for unread conversations
      tileColor: conversation.hasNewMessages
          ? AppColors.primaryColor.withOpacity(0.05)
          : null,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final hasMessage = conversation.latestMessage?.isNotEmpty == true;

    return Text(
      hasMessage
          ? conversation.latestMessage!
          : AppLocalizations.of(context)!.noMessagesYet,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: hasMessage
            ? (conversation.hasNewMessages ? Colors.black87 : Colors.black54)
            : Colors.grey[600],
        fontSize: 14,
        fontWeight:
            conversation.hasNewMessages ? FontWeight.w500 : FontWeight.normal,
        fontStyle: hasMessage ? FontStyle.normal : FontStyle.italic,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          ChatUtils.formatMessageTime(conversation.time),
          style: TextStyle(
            fontSize: 12,
            color: conversation.hasNewMessages
                ? AppColors.primaryColor
                : Colors.grey,
            fontWeight: conversation.hasNewMessages
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        if (conversation.hasNewMessages)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AppLocalizations.of(context)!.newMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          otherUserId: conversation.user.id.toString(),
          otherUserName: conversation.user.fullName.isNotEmpty
              ? conversation.user.fullName
              : AppLocalizations.of(context)!.unknownUser,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  final bool isConnected;

  const _EmptyState({
    required this.onRefresh,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: context.getAdaptiveSize(80),
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.noConversations,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.startNewConversation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isConnected) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.wifi),
                    label: Text(AppLocalizations.of(context)!.reconnect),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
