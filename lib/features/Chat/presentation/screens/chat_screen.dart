import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/user_helper.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/Chat/Models/chat_message.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen(
      {super.key, required this.otherUserId, required this.otherUserName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isInitialized = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _isInitialized) {
      // Refresh chat when app comes to foreground
      _refreshIfNeeded();
    }
  }

  Future<void> _initialize() async {
    if (_isInitializing) return;

    _isInitializing = true;

    try {
      final provider = context.read<ChatProvider>();

      // Get user ID using the helper utility
      final userId = UserHelper.getCurrentUserId(context);

      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not available - please log in again');
      }

      debugPrint('ChatScreen: Initializing with User ID: $userId');

      // Initialize provider if not already done or if user changed
      if (!provider.isConnected || provider.currentUserId != userId) {
        await provider.initialize(userId);
      }

      // Ensure we're connected before initializing chat
      if (provider.isConnected) {
        await provider.initializeChat(widget.otherUserId);
      } else {
        throw Exception('Failed to connect to chat server');
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Chat initialization error: $e');
      // The error will be shown through provider state
    } finally {
      _isInitializing = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _refreshIfNeeded() async {
    final provider = context.read<ChatProvider>();

    if (!provider.isConnected) {
      await _initialize();
    }
  }

  Future<void> _handleRetry() async {
    await _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return WillPopScope(
          onWillPop: () async {
            // Clean up when leaving chat
            _focusNode.unfocus();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => Navigator.pop(context)),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.otherUserName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Connection indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: provider.isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              titleSpacing: 0,
              actions: [
                if (!provider.isConnected)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _handleRetry,
                    tooltip: AppLocalizations.of(context)!.reconnect,
                  ),
              ],
            ),
            body: Column(
              children: [
                Expanded(child: _buildChatContent(provider)),
                _MessageInput(
                  controller: _controller,
                  focusNode: _focusNode,
                  otherUserId: widget.otherUserId,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatContent(ChatProvider provider) {
    if (!_isInitialized && _isInitializing) {
      return _LoadingState(
          message: AppLocalizations.of(context)!.connectingToChat);
    }

    if (provider.isLoadingMessages) {
      return _LoadingState(
          message: AppLocalizations.of(context)!.loadingMessages);
    }

    if (provider.error != null) {
      return _ErrorState(
        error: provider.error!,
        onRetry: _handleRetry,
        isConnected: provider.isConnected,
      );
    }

    if (provider.messages.isEmpty) {
      return _EmptyMessages(
        otherUserName: widget.otherUserName,
        isConnected: provider.isConnected,
        onRetry: _handleRetry,
      );
    }

    return _OptimizedMessageList(provider: provider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _OptimizedMessageList extends StatelessWidget {
  final ChatProvider provider;

  const _OptimizedMessageList({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: provider.scrollController,
      reverse: true,
      padding: EdgeInsets.all(context.getWidth(16)),
      itemCount: provider.messages.length,
      // Add item extent for better performance
      itemExtent: null, // Let it calculate automatically
      cacheExtent: 1000, // Cache more items
      itemBuilder: (context, index) {
        final message = provider.messages[provider.messages.length - 1 - index];
        return _MessageBubble(
          message: message,
          isMe: message.userId == provider.currentUserId,
          // Add key for better widget recycling
          key: ValueKey(
              '${message.userId}_${message.timestamp.millisecondsSinceEpoch}'),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
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

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String otherUserId;

  const _MessageInput({
    required this.controller,
    required this.focusNode,
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.all(context.getWidth(8)),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: provider.isConnected,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: provider.isConnected
                          ? AppLocalizations.of(context)!.typeMessage
                          : AppLocalizations.of(context)!.connecting,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      suffixIcon: provider.isConnected
                          ? null
                          : const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                    ),
                    onSubmitted: provider.isConnected
                        ? (text) => _sendMessage(provider, text)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppColors.primaryColor,
                  onPressed: provider.isConnected
                      ? () => _sendMessage(provider, controller.text)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sendMessage(ChatProvider provider, String text) {
    if (text.trim().isNotEmpty) {
      provider.sendMessage(text.trim(), otherUserId);
      controller.clear();
      focusNode.requestFocus();
    }
  }
}

class _LoadingState extends StatelessWidget {
  final String message;

  const _LoadingState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
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
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(isConnected ? Icons.refresh : Icons.wifi),
              label: Text(isConnected
                  ? AppLocalizations.of(context)!.retry
                  : AppLocalizations.of(context)!.reconnect),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  final String otherUserName;
  final bool isConnected;
  final VoidCallback onRetry;

  const _EmptyMessages({
    required this.otherUserName,
    required this.isConnected,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '${AppLocalizations.of(context)!.startConversationWith}: $otherUserName',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          if (!isConnected) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.wifi),
              label: Text(AppLocalizations.of(context)!.reconnect),
            ),
          ],
        ],
      ),
    );
  }
}
