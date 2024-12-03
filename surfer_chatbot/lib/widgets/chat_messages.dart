import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import 'message_bubble.dart';

class ChatMessages extends ConsumerWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider);
    final isLoading = ref.watch(isChatLoadingProvider);

    return Stack(
      children: [
        ListView.builder(
          reverse: false, // Changed to false to show newer messages at bottom
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
