import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';

// State class to handle chat state
class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Chat notifier to handle chat logic
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState());

  void sendMessage(String content) {
    // Add user message
    final userMessage = Message(
      content: content,
      isUser: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    // TODO: Implement actual bot response
    // For now, just echo back
    _simulateBotResponse(content);
  }

  void _simulateBotResponse(String userMessage) {
    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      final botMessage = Message(
        content: "You said: $userMessage",
        isUser: false,
      );

      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );
    });
  }

  void clearChat() {
    state = ChatState();
  }

  void removeMessage(String messageId) {
    state = state.copyWith(
      messages: state.messages.where((msg) => msg.id != messageId).toList(),
    );
  }
}

// Providers
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

// Provider for loading state
final isChatLoadingProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider).isLoading;
});

// Provider for messages list
final messagesProvider = Provider<List<Message>>((ref) {
  return ref.watch(chatProvider).messages;
});

// Provider for error state
final chatErrorProvider = Provider<String?>((ref) {
  return ref.watch(chatProvider).error;
});