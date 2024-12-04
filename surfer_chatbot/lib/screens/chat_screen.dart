import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/surf_conditions_provider.dart';
import '../widgets/surf_quality_panel.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_messages.dart';
import '../widgets/rive_bot_animation.dart';
import '../providers/location_provider.dart';
import '../providers/user_provider.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final userProfile = ref.watch(userProfileProvider);
    final selectedSpot = ref.watch(chatProvider).lastSpotMentioned;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: userProfile.avatarUrl != null
                  ? NetworkImage(userProfile.avatarUrl!)
                  : null,
              child: userProfile.avatarUrl == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              '${userProfile.name} • ${userProfile.heightCm}cm • ${userProfile.weightKg}kg',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          if (locationState.location != null) ...[
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 4),
            Text(
              'San Diego, California',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(width: 16),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(locationProvider.notifier).getCurrentLocation(),
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
                Expanded(child: ChatMessages()),
                Divider(height: 1),
                ChatInput(),
              ],
            ),
          ),

          // Right side - Info Panel
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Top section - Animation
                const RiveBotAnimation(),

                // Bottom section - Surf Quality Rating
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final surfConditions = ref.watch(surfConditionsProvider);
                      return SurfQualityPanel(
                        rating: surfConditions.rating,
                        confidence: surfConditions.confidence,
                        factors: surfConditions.factors,
                        factorDescriptions: surfConditions.factorDescriptions,
                      );
                    },
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
        title: const Text('About OpenSurf Bot'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This chatbot features:'),
            SizedBox(height: 8),
            Text('• Animated bot character'),
            Text('• Location awareness'),
            Text('• Enhanced ML predictions'),
            Text('• Real-time surf conditions'),
            Text('• Wave analysis'),
            Text('• Board recommendations'),
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
