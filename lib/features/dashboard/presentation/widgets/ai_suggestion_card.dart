import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';

class AiSuggestionCard extends StatelessWidget {
  final String suggestion;
  final bool isLoading;

  const AiSuggestionCard({super.key, required this.suggestion, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('AI Suggestion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          isLoading
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(suggestion, style: const TextStyle(color: Colors.white, height: 1.4)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.push('/ai-chat'),
            style: TextButton.styleFrom(foregroundColor: Colors.white, padding: EdgeInsets.zero),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text('Chat with AI Tutor'), Icon(Icons.arrow_forward, size: 16)],
            ),
          ),
        ],
      ),
    );
  }
}
