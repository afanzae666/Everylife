import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/event/npc_interaction_outcome.dart';
import '../../domain/character/life_stage.dart';
import '../widgets/info_line.dart';
import '../widgets/animated_dialog.dart';
import '../widgets/game_bar.dart';

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
    this.netWorth,
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

  /// Formatted net worth; only shown for NPCs aged 18 or more.
  final String? netWorth;

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
      transitionDuration: const Duration(milliseconds: 260),
    transitionBuilder: animatedDialogTransition,
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
    final scheme = theme.colorScheme;
    final score = _score.clamp(-100, 100).toInt();
    final age = widget.birthYear != null && widget.currentYear != null
        ? (widget.currentYear! - widget.birthYear!).clamp(0, 150).toInt()
        : null;

    showAnimatedDialog<void>(
      context: context,
      builder: (dialogContext) => Center(
        child: SingleChildScrollView(
          child: Container(
            key: const Key('npc-details-dialog'),
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.primary, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: scheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.relationship.toUpperCase(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        InkWell(
                          key: const Key('npc-details-close'),
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(Icons.close, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.45),
                            ),
                          ),
                          child: SizedBox(
                            width: 96,
                            height: 120,
                            child: widget.avatar ??
                                const Icon(Icons.person_outline, size: 56),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Relationship · ${_bondLabel(score)} · $score%',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              GameBar(
                                barKey: const Key('npc-details-relationship-bar'),
                                value: score.abs() / 100,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Basic Information',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              if (age != null)
                                InfoLine(label: 'Age', value: '$age'),
                              for (final entry in widget.details)
                                InfoLine(label: entry.key, value: entry.value),
                              if (widget.netWorth != null &&
                                  age != null &&
                                  age >= 18)
                                InfoLine(
                                  label: 'Net Worth',
                                  value: widget.netWorth!,
                                ),
                              if (widget.subtitle != null &&
                                  widget.details.isEmpty)
                                Text(widget.subtitle!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                        GameBar(value: score.abs() / 100),
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
