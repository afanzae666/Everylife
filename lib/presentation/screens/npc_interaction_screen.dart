import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/event/npc_interaction_outcome.dart';

class NpcInteractionScreen extends StatefulWidget {
  const NpcInteractionScreen({
    required this.npcId,
    required this.name,
    required this.relationship,
    required this.relationshipPercent,
    required this.onInteraction,
    this.subtitle,
    this.avatar,
    this.birthYear,
    this.currentYear,
    this.isAlive = true,
    super.key,
  });

  final String npcId;
  final String name;
  final String relationship;
  final int relationshipPercent;
  final Result<NpcInteractionOutcome> Function({
    required String npcId,
    required String action,
  }) onInteraction;
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
  bool _hadArgument = false;
  bool _showingNarrative = false;

  void _interact(String action) {
    if (!widget.isAlive || _showingNarrative) return;
    final result = widget.onInteraction(npcId: widget.npcId, action: action);
    switch (result) {
      case Success<NpcInteractionOutcome>(:final value):
        setState(() {
          _score = value.relationshipPercent;
          if (action == 'Argue') _hadArgument = true;
          if (action == 'Apologize') _hadArgument = false;
          _showingNarrative = true;
        });
        _showNarrative(value.narrative);
      case Failure<NpcInteractionOutcome>(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _showNarrative(String narrative) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss interaction narrative',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (dialogContext, _, __) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(dialogContext).pop(),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(dialogContext).pop(),
              child: Dialog(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(narrative, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      const Text('Tap anywhere to continue', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (mounted) setState(() => _showingNarrative = false);
  }

  void _showDetails() {
    if (!widget.isAlive) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: SizedBox(width: 112, height: 140, child: widget.avatar ?? const Icon(Icons.person_outline, size: 64))),
                const SizedBox(height: 8),
                Text(widget.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(widget.relationship, textAlign: TextAlign.center),
                if (widget.birthYear != null && widget.currentYear != null)
                  Text('Age ${(widget.currentYear! - widget.birthYear!).clamp(0, 150)}', textAlign: TextAlign.center),
                if (widget.subtitle != null) ...[const SizedBox(height: 12), Text(widget.subtitle!)],
                const SizedBox(height: 12),
                Text('Relationship · $_score%'),
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
    final color = score >= 0 ? const Color(0xFF32CD62) : const Color(0xFFFF4545);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
        title: Text(widget.relationship),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: InkWell(
              onTap: widget.isAlive ? _showDetails : null,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    SizedBox(width: 56, height: 70, child: FittedBox(fit: BoxFit.contain, child: widget.avatar ?? const Icon(Icons.person_outline, size: 48))),
                    const SizedBox(width: 6),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(widget.relationship, style: Theme.of(context).textTheme.labelSmall),
                        const SizedBox(height: 3),
                        ClipRRect(borderRadius: BorderRadius.zero, child: LinearProgressIndicator(minHeight: 7, value: score.abs() / 100, color: color, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest)),
                        const SizedBox(height: 3),
                        Text('Relationship · $score%'),
                      ],
                    )),
                    IconButton(onPressed: widget.isAlive ? _showDetails : null, icon: const Text('•••')),
                  ],
                ),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(8), child: Text('Interactions')),
          for (final action in const ['Talk', 'Spend Time', 'Compliment', 'Help', 'Argue'])
            _ActionRow(title: action, onPressed: widget.isAlive ? () => _interact(action) : null),
          if (_hadArgument) _ActionRow(title: 'Apologize', onPressed: widget.isAlive ? () => _interact('Apologize') : null),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.title, required this.onPressed});
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    child: ListTile(
      title: Text(title),
      trailing: const Text('•••'),
      onTap: onPressed,
      enabled: onPressed != null,
    ),
  );
}
