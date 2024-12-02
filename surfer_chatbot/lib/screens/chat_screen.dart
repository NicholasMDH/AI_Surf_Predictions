import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_messages.dart';
import '../widgets/location_display.dart';
import '../widgets/rive_bot_animation.dart';
import '../widgets/user_profile_display.dart';
import '../providers/location_provider.dart';
import '../providers/user_provider.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final isLoading = ref.watch(isLocationLoadingProvider);
    final error = ref.watch(locationErrorProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenSurf Bot'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Location',
            onPressed: () {
              ref.read(locationProvider.notifier).getCurrentLocation();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - Chat
          const Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: ChatMessages(),
                ),
                Divider(height: 1),
                ChatInput(),
              ],
            ),
          ),

          // Right side - Animation and Info Row
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Top section - Rive Bot Animation
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 36, 34, 40),
                          // color: const Color(0xFF1F1F1F),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const RiveBotAnimation(),
                      ),
                    ),
                  ),
                ),

                // Bottom section - User Profile and Location
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: IntrinsicHeight( // This ensures both boxes have same height
                      child: Row(
                        children: [
                          // Left side - User Profile
                          Expanded(
                            child: SizedBox.expand(
                              child: UserProfileDisplay(user: userProfile),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Right side - Location Display
                          Expanded(
                            child: SizedBox.expand(
                              child: LocationDisplay(
                                location: locationState.location,
                                isLoading: isLoading,
                                error: error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Chatbot'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This chatbot demo features:'),
            SizedBox(height: 8),
            Text('• Animated bot character'),
            Text('• Location awareness with address lookup'),
            Text('• Message history'),
            Text('• Real-time responses'),
            Text('• User profile display'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}