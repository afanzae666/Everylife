import 'package:flutter/material.dart';

/// Basic interaction destination for a living NPC.
///
/// Relationship changes in this first UI pass are kept in the screen state.
/// Durable relationship updates require a simulation command/state mutation
/// path and are intentionally not faked here.
class NpcInteractionScreen extends StatefulWidget {
  const NpcInteractionScreen({
    required this.name,
    required this.relationship,
    required this.relationshipPercent,
    this.subtitle,
    this.avatar,
    this.birthYear,
    this.currentYear,
    this.isAlive = true,
    super.key,
  });

  final String name;
  final String relationship;
  final int relationshipPercent;
  final String? subtitle;
  final Widget? avatar;
  final int? birthYear;
  final int? currentYear;
  final bool isAlive;

  @override
  State<NpcInteractionScreen> createState() => _NpcInteractionScreenState();
}

class _NpcInteractionScreenState extends State<NpcInteractionScreen> {
  late int _score = widget.relationshipPercent.clamp(-100, 100).toInt();
  String? _lastResponse;
  bool _hadArgument = false;

  void _interact(String action) {
    if (!widget.isAlive) return;

    final (change, response) = switch (action) {
      'Talk' => (2, '${widget.name} talks with you.'),
      'Spend Time' => (5, 'You spend some time with ${widget.name}.'),
      'Compliment' => (3, '${widget.name} responds to your compliment.'),
      'Help' => (4, 'You offer help to ${widget.name}.'),
      'Argue' => (-8, 'You argue with ${widget.name}.'),
      'Apologize' => (4, 'You apologize to ${widget.name}.'),
      _ => (0, 'Nothing happened.'),
    };

    setState(() {
      _score = (_score + change).clamp(-100, 100).toInt();
      _lastResponse = response;
      if (action == 'Argue') _hadArgument = true;
      if (action == 'Apologize') _hadArgument = false;
    });
  }

  void _showDetails() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SizedBox(
                    width: 112,
                    height: 140,
                    child: widget.avatar ??
                        const Icon(Icons.person_outline, size: 64),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(widget.relationship, textAlign: TextAlign.center),
                if (widget.birthYear != null && widget.currentYear != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Age ${((widget.currentYear! - widget.birthYear!).clamp(0, 150))}',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 12),
                  Text(widget.subtitle!),
                ],
                const SizedBox(height: 12),
                Text('Relationship · $_score%'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = _score.clamp(-100, 100).toInt();
    final positive = score >= 0;
    final color = positive
        ? const Color(0xFF32CD62)
        : const Color(0xFFFF4545);
    final progress = score.abs() / 100;

    return Scaffold(
      appBar: AppBar(title: const Text('NPC Interaction')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Card(
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: InkWell(
              onTap: widget.isAlive ? _showDetails : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 112,
                        height: 140,
                        child: widget.avatar ??
                            const Icon(Icons.person_outline, size: 64),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(widget.relationship, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: progress,
                        color: color,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('Relationship · $score%'),
                    const SizedBox(height: 4),
                    const Center(child: Text('Tap profile for more information')),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Interactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final action in const [
            'Talk',
            'Spend Time',
            'Compliment',
            'Help',
            'Argue',
          ])
            _ActionRow(
              title: action,
              onPressed: widget.isAlive ? () => _interact(action) : null,
            ),
          if (_hadArgument)
            _ActionRow(
              title: 'Apologize',
              onPressed: widget.isAlive ? () => _interact('Apologize') : null,
            ),
          if (_lastResponse != null)
            Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_lastResponse!),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.onPressed,
  });

  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPressed,
        enabled: onPressed != null,
      ),
    );
  }
}
