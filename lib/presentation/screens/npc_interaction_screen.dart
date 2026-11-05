import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/event/npc_interaction_outcome.dart';
import '../../domain/character/life_stage.dart';
import '../widgets/info_line.dart';

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
    this.playerAge = 18,
    this.isAlive = true,
    this.details = const <MapEntry<String, String>>[],
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
  final int playerAge;
  final bool isAlive;

  /// Extra facts shown in the information overlay (label, value).
  final List<MapEntry<String, String>> details;

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
        _showNarrative(value.narrative, progressed: value.progressed);
      case Failure<NpcInteractionOutcome>(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _showNarrative(String narrative, {bool progressed = true}) async {
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(narrative, style: Theme.of(context).textTheme.bodyLarge),
                      if (!progressed) ...[
                        const SizedBox(height: 12),
                        Text(
                          'We already did this recently, so our bond '
                          "didn't change.",
                          key: const Key('interaction-no-progress-note'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text('Tap anywhere to close', textAlign: TextAlign.center),
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

  static String _bondLabel(int score) {
    if (score >= 75) return 'Very close';
    if (score >= 50) return 'Close';
    if (score >= 25) return 'Friendly';
    if (score >= 0) return 'Distant';
    if (score >= -50) return 'Strained';

    return 'Hostile';
  }

  void _showDetails() {
    if (!widget.isAlive) return;
    final theme = Theme.of(context);
    final score = _score.clamp(-100, 100).toInt();
    final barColor =
        score >= 0 ? const Color(0xFF32CD62) : const Color(0xFFFF4545);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        key: const Key('npc-details-dialog'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: SizedBox(width: 112, height: 140, child: widget.avatar ?? const Icon(Icons.person_outline, size: 64))),
                const SizedBox(height: 8),
                Text(widget.name, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  widget.relationship,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text('Relationship', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Text('${_bondLabel(score)} · $score%', style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    key: const Key('npc-details-relationship-bar'),
                    minHeight: 10,
                    value: score.abs() / 100,
                    color: barColor,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.birthYear != null && widget.currentYear != null)
                  InfoLine(
                    label: 'Age',
                    value: '${(widget.currentYear! - widget.birthYear!).clamp(0, 150)}',
                  ),
                for (final entry in widget.details)
                  InfoLine(label: entry.key, value: entry.value),
                if (widget.subtitle != null && widget.details.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(widget.subtitle!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> get _availableActions {
    final stage = LifeStageAge.fromAge(widget.playerAge.clamp(0, 150).toInt());
    if (stage == LifeStage.infant) return const [];

    const basic = ['Talk', 'Spend Time', 'Compliment', 'Help'];
    if (stage == LifeStage.toddler || stage == LifeStage.child) {
      return basic;
    }
    return const ['Talk', 'Spend Time', 'Compliment', 'Help', 'Argue'];
  }

  @override
  Widget build(BuildContext context) {
    final score = _score.clamp(-100, 100).toInt();
    final color = score >= 0 ? const Color(0xFF32CD62) : const Color(0xFFFF4545);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
        title: Text(
          widget.relationship.toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
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
                        Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
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
          if (_availableActions.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.all(8), child: Text('Interactions')),
            for (final action in _availableActions)
              _ActionRow(
                title: action,
                onPressed: widget.isAlive ? () => _interact(action) : null,
              ),
            if (_hadArgument && widget.playerAge >= 13)
              _ActionRow(
                title: 'Apologize',
                onPressed:
                    widget.isAlive ? () => _interact('Apologize') : null,
              ),
          ],
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
