import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';

class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
  final String? lastSpotMentioned; // Add this to maintain context

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.lastSpotMentioned,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
    String? lastSpotMentioned,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastSpotMentioned: lastSpotMentioned ?? this.lastSpotMentioned,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState());

  void sendMessage(String content) async {
    // Add user message
    final userMessage = Message(
      content: content,
      isUser: true,
      status: MessageStatus.sent,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      print("Sending chat message to API: $content");

      // If it's a "yes" response and we have a last spot mentioned, append the spot name
      String apiContent = content;
      if (content.toLowerCase() == 'yes' && state.lastSpotMentioned != null) {
        apiContent = '$content for ${state.lastSpotMentioned}';
      }

      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: json.encode({'input': apiContent}),
      );
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('response')) {
          String botResponse = data['response'] as String;

          // Update lastSpotMentioned if this message mentions a new spot
          // This would need a function to extract spot names from the response
          if (botResponse.contains('Pacific Beach Pier')) {
            state = state.copyWith(lastSpotMentioned: 'Pacific Beach Pier');
          } else if (botResponse.contains('Coronado Beaches')) {
            state = state.copyWith(lastSpotMentioned: 'Coronado Beaches');
          } // Add other spots as needed

          sendBotMessage(botResponse);
        } else {
          print("Unexpected API response format: $data");
          sendBotMessage(
              "Sorry, I received an unexpected response format. Please try again.");
        }
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        sendBotMessage(
            "Sorry, I'm having trouble understanding right now. Please try again.");
      }
    } catch (e) {
      print('Error communicating with bot: $e');
      sendBotMessage(
          "Sorry, I'm having technical difficulties. Please try again later.");
    }

    state = state.copyWith(isLoading: false);
  }

  void sendBotMessage(String content) {
    final botMessage = Message(
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    state = state.copyWith(
      messages: [...state.messages, botMessage],
      isLoading: false,
    );
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

final isChatLoadingProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider).isLoading;
});

final messagesProvider = Provider<List<Message>>((ref) {
  return ref.watch(chatProvider).messages;
});

final chatErrorProvider = Provider<String?>((ref) {
  return ref.watch(chatProvider).error;
});
