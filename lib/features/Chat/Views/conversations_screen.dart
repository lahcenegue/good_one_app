import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
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
      // onTap: () => Navigator.pushNamed(
      //   context,
      //   AppRoutes.chat,
      //   arguments: {
      //     'otherUserId': conversation.user.id.toString(),
      //     'otherUserName': conversation.user.fullName,
      //   },
      // ),
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

// import 'package:flutter/material.dart';
// import 'package:good_one_app/Core/Utils/size_config.dart';
// import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
// import 'package:provider/provider.dart';
// import '../../../Core/Navigation/app_routes.dart';
// import '../../../Core/presentation/Widgets/user_avatar.dart';
// import '../../../Providers/chat_provider.dart';
// import '../../../Providers/user_manager_provider.dart';
// import '../Widgets/chat_utils.dart';

// class ConversationsScreen extends StatefulWidget {
//   const ConversationsScreen({super.key});

//   @override
//   State<ConversationsScreen> createState() => _ConversationsScreenState();
// }

// class _ConversationsScreenState extends State<ConversationsScreen> {
//   final ScrollController _scrollController = ScrollController();
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeConversations();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeConversations() async {
//     if (_isInitialized) return;

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final userId =
//           context.read<UserManagerProvider>().userInfo?.id.toString();
//       if (userId != null) {
//         final chatProvider = context.read<ChatProvider>();

//         // Initialize WebSocket if not already connected
//         if (!chatProvider.isConnected) {
//           await chatProvider.initialize(userId);
//         }

//         // Wait for connection and fetch conversations
//         bool isConnected = await chatProvider.waitForConnection();
//         if (isConnected) {
//           await chatProvider.initializeConversations();
//           _isInitialized = true;

//           // Scroll to bottom after data is loaded
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _scrollToBottom();
//           });
//         } else {
//           // If connection failed, retry after delay
//           Future.delayed(const Duration(seconds: 2), _initializeConversations);
//         }
//       }
//     });
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   Future<void> _refreshConversations() async {
//     final chatProvider = context.read<ChatProvider>();
//     await chatProvider.initializeConversations();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Messages',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Consumer<ChatProvider>(
//         builder: (context, chatProvider, _) {
//           if (chatProvider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (chatProvider.error != null) {
//             return _buildErrorState(chatProvider.error!, context);
//           }

//           if (!chatProvider.isConnected) {
//             return _buildConnectingState();
//           }

//           if (chatProvider.conversations.isEmpty) {
//             return _buildEmptyState();
//           }

//           return RefreshIndicator(
//             onRefresh: _refreshConversations,
//             child: ListView.separated(
//               controller: _scrollController,
//               physics: const AlwaysScrollableScrollPhysics(),
//               itemCount: chatProvider.conversations.length,
//               separatorBuilder: (context, index) => Divider(
//                 indent: context.getWidth(20),
//                 endIndent: context.getWidth(20),
//               ),
//               itemBuilder: (context, index) {
//                 final conversation = chatProvider.conversations[index];
//                 return ListTile(
//                   onTap: () => Navigator.pushNamed(
//                     context,
//                     AppRoutes.chat,
//                     arguments: {
//                       'otherUserId': conversation.user.id.toString(),
//                       'otherUserName': conversation.user.fullName,
//                     },
//                   ),
//                   leading: UserAvatar(
//                     picture: conversation.user.picture,
//                     size: context.getWidth(60),
//                     backgroundColor: Colors.white,
//                   ),
//                   title: Text(
//                     conversation.user.fullName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                     ),
//                   ),
//                   subtitle: Text(
//                     conversation.latestMessage ?? 'No messages yet',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 14,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   trailing: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         ChatUtils.formatMessageTime(conversation.time),
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 12,
//                         ),
//                       ),
//                       if (conversation.hasNewMessages)
//                         Container(
//                           margin: const EdgeInsets.only(top: 4),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColors.primaryColor,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Text(
//                             'NEW',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildConnectingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(),
//           const SizedBox(height: 16),
//           Text(
//             'Connecting to chat server...',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return RefreshIndicator(
//       onRefresh: _refreshConversations,
//       child: ListView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         children: [
//           SizedBox(
//             height: context.getHeight(400),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.chat_bubble_outline,
//                     size: context.getAdaptiveSize(64),
//                     color: Colors.grey[400],
//                   ),
//                   SizedBox(height: context.getHeight(16)),
//                   Text(
//                     'No conversations yet',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: context.getHeight(8)),
//                   Text(
//                     'Start a new conversation with someone',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[500],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String error, BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 48,
//             color: Colors.red[400],
//           ),
//           SizedBox(height: context.getHeight(16)),
//           const Text(
//             'Something went wrong',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: context.getHeight(8)),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32),
//             child: Text(
//               error,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _refreshConversations,
//             child: const Text('Try Again'),
//           ),
//         ],
//       ),
//     );
//   }
// }
