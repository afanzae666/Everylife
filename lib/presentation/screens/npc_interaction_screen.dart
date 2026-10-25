import 'package:flutter/material.dart';

/// Placeholder destination for NPC cards. Interaction actions are intentionally
/// deferred until their gameplay rules are designed.
class NpcInteractionScreen extends StatelessWidget {
  const NpcInteractionScreen({
    required this.name,
    required this.relationship,
    required this.relationshipPercent,
    this.subtitle,
    super.key,
  });

  final String name;
  final String relationship;
  final int relationshipPercent;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final score = relationshipPercent.clamp(-100, 100).toInt();
    final positive = score > 0;
    final color = positive ? const Color(0xFF32CD62) : const Color(0xFFFF4545);
    final progress = score >= 0 ? score / 100 : score.abs() / 100;

    return Scaffold(
      appBar: AppBar(title: const Text('NPC Interaction')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(relationship, style: Theme.of(context).textTheme.bodyMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!),
                  ],
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      value: progress.toDouble(),
                      color: color,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('Relationship · $score%'),
                  const SizedBox(height: 8),
                  const Text('NPC interactions will be added in a later update.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
