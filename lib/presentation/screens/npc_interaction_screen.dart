import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/event/npc_interaction_outcome.dart';
import '../../domain/character/life_stage.dart';
import '../widgets/info_line.dart';
import '../widgets/themed_cards.dart';
import '../widgets/animated_dialog.dart';
import '../widgets/game_bar.dart';
import '../widgets/id_card_frame.dart';
import '../widgets/life_labels.dart' show countryFlag;
import '../widgets/modal_cards.dart';
import '../widgets/page_top_bar.dart';

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
    this.countryCode,
    this.zoom = 1,
    this.headerBuilder,
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

  /// Country of the NPC; its flag is shown next to the name.
  final String? countryCode;

  /// UI scale and the player's character card shown at the top of the page.
  final double zoom;
  final WidgetBuilder? headerBuilder;

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
        _showNarrative(
          value.narrative,
          progressed: value.progressed,
          action: action,
        );
      case Failure<NpcInteractionOutcome>(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _showNarrative(
    String narrative, {
    bool progressed = true,
    String action = '',
  }) async {
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
          child: InteractionCard(
            avatar: widget.avatar,
            emoji: _actionInfo[action]?.$1 ?? '💬',
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
                const SizedBox(height: 14),
                Text(
                  'Tap anywhere to close',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (mounted) setState(() => _showingNarrative = false);
  }

  static const Map<String, (String, String)> _actionInfo = {
    'Talk': ('💬', 'Have a chat'),
    'Spend Time': ('🎈', 'Do something together'),
    'Compliment': ('💐', 'Say something kind'),
    'Help': ('🤝', 'Lend a hand'),
    'Argue': ('💢', 'Start a fight'),
    'Apologize': ('🙏', 'Make things right'),
  };

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

    final flag = countryFlag(widget.countryCode);

    showAnimatedDialog<void>(
      context: context,
      builder: (dialogContext) => IdCardFrame(
        key: const Key('npc-details-dialog'),
        title: widget.relationship.toUpperCase(),
        onClose: () => Navigator.of(dialogContext).pop(),
        footer: widget.netWorth != null && age != null && age >= 18
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('WEALTH'),
                  const SizedBox(height: 3),
                  WealthPanel(label: 'Net Worth', value: widget.netWorth!),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 112,
                        height: 140,
                        child: widget.avatar ??
                            const Icon(Icons.person_outline, size: 56),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (flag.isNotEmpty) ...[
                            Text(flag, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              widget.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
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
                      const SectionTitle('Basic Information'),
                      const SizedBox(height: 2),
                      ...withThinLines(context, [
                        if (age != null) InfoLine(label: 'Age', value: '$age'),
                        for (final entry in widget.details)
                          InfoLine(label: entry.key, value: entry.value),
                      ]),
                      if (widget.subtitle != null && widget.details.isEmpty)
                        Text(widget.subtitle!),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(widget.zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (widget.headerBuilder != null) widget.headerBuilder!(context),
              PageTopBar(title: widget.relationship, zoom: widget.zoom),
              Expanded(
                child: ListView(
        padding: EdgeInsets.zero,
        children: [
          AccentCard(
            zoom: widget.zoom,
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
                    ChevronBadge(zoom: widget.zoom),
                  ],
                ),
              ),
            ),
          ),
          if (_availableActions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SectionDivider(title: 'INTERACTIONS', zoom: widget.zoom),
            ),
            AccentCard(
              zoom: widget.zoom,
              child: Column(
                children: [
                  for (var i = 0; i < _availableActions.length; i++) ...[
                    if (i > 0) const _ThinLine(),
                    _ActionRow(
                      title: _availableActions[i],
                      emoji: _actionInfo[_availableActions[i]]?.$1 ?? '💬',
                      description: _actionInfo[_availableActions[i]]?.$2 ?? '',
                      onPressed: widget.isAlive
                          ? () => _interact(_availableActions[i])
                          : null,
                    ),
                  ],
                  if (_hadArgument && widget.playerAge >= 13) ...[
                    const _ThinLine(),
                    _ActionRow(
                      title: 'Apologize',
                      emoji: _actionInfo['Apologize']!.$1,
                      description: _actionInfo['Apologize']!.$2,
                      onPressed:
                          widget.isAlive ? () => _interact('Apologize') : null,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.emoji,
    required this.description,
    required this.onPressed,
  });

  final String title;
  final String emoji;
  final String description;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onPressed,
      child: Opacity(
        opacity: onPressed == null ? 0.45 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primary, width: 1.5),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(description, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const ChevronBadge(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThinLine extends StatelessWidget {
  const _ThinLine();

  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
      );
}
