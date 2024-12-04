import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import 'message_bubble.dart';

class ChatMessages extends ConsumerStatefulWidget {
  const ChatMessages({super.key});

  @override
  ConsumerState<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends ConsumerState<ChatMessages> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider);
    final isLoading = ref.watch(isChatLoadingProvider);

    // Trigger scroll to bottom when messages change
    if (messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final showTime = index == messages.length - 1 ||
                messages[index + 1]
                        .timestamp
                        .difference(message.timestamp)
                        .inMinutes >
                    2;

            return MessageBubble(
              key: ValueKey(message.id),
              message: message,
              showTime: showTime,
            );
          },
        ),
        if (isLoading)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              padding: const EdgeInsets.all(8.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Bot is typing...'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
