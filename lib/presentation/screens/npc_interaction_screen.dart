import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/event/npc_interaction_outcome.dart';
import '../../domain/character/fertility.dart';
import '../../domain/character/gender.dart';
import '../../domain/character/life_stage.dart';
import '../../domain/love/love_state.dart';
import '../../domain/social/social_rules.dart';
import '../widgets/info_line.dart';
import '../widgets/themed_cards.dart';
import '../widgets/animated_dialog.dart';
import '../widgets/id_card_frame.dart';
import '../widgets/life_labels.dart' show countryFlag;
import '../widgets/love_milestones.dart';
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
    this.traits,
    this.befriendable = false,
    this.bond = 'none',
    this.romanceEligible = false,
    this.romance = 'none',
    this.playerHasPartner = false,
    this.canUseBirthControl = false,
    this.onBirthControl = false,
    this.countryCode,
    this.zoom = 1,
    this.headerBuilder,
    this.milestones,
    this.gender,
    this.stage = LoveRules.stageDating,
    this.playerName,
    this.wasSpouse = false,
    this.childrenCount = 0,
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

  /// Looks, smarts and fertility, shown as bars in the information overlay.
  final NpcTraits? traits;

  /// True for people the player can ask to be friends (classmates).
  final bool befriendable;

  /// 'none', 'friend' or 'best friend' when the page opens.
  final String bond;

  /// True for people the player may date (classmates and friends).
  final bool romanceEligible;

  /// 'partner' when this person is the player's boyfriend or girlfriend.
  final String romance;

  /// True when the player already has a partner (someone else).
  final bool playerHasPartner;

  /// True for a female partner, who can use birth control.
  final bool canUseBirthControl;
  final bool onBirthControl;

  /// Country of the NPC; its flag is shown next to the name.
  final String? countryCode;

  /// UI scale and the player's character card shown at the top of the page.
  final double zoom;
  final WidgetBuilder? headerBuilder;

  /// Engagement, marriage and divorce (partners only).
  final LoveMilestones? milestones;

  /// Used for words like girlfriend, fiancé and ex-wife.
  final Gender? gender;

  /// 'dating', 'engaged' or 'married' when this is the player's partner.
  final String stage;
  final String? playerName;

  /// True for an ex who was once married to the player.
  final bool wasSpouse;

  /// Children the player has with this person.
  final int childrenCount;

  @override
  State<NpcInteractionScreen> createState() => _NpcInteractionScreenState();
}

class _NpcInteractionScreenState extends State<NpcInteractionScreen> {
  late int _score = widget.relationshipPercent.clamp(-100, 100).toInt();
  bool _hadArgument = false;
  bool _showingNarrative = false;
  late String _bond = widget.bond;
  late String _romance = widget.romance;
  late bool _onPill = widget.onBirthControl;
  late String _stage = widget.stage;
  late bool _wasSpouse = widget.wasSpouse;

  /// True when both the player and this person are at least 18.
  bool get _bothAdults {
    final birth = widget.birthYear;
    final year = widget.currentYear;

    if (birth == null || year == null) return false;

    return LoveRules.canBeIntimate(widget.playerAge, year - birth);
  }

  /// The current relationship, which changes as the person becomes a
  /// friend, a best friend or a partner.
  String get _relationshipLabel {
    final gender = widget.gender;

    if (_romance == 'partner') {
      return gender == null
          ? 'partner'
          : LoveRules.partnerLabel(_stage, gender).toLowerCase();
    }

    if (_bond == 'ex') {
      return LoveRules.exLabel(gender ?? Gender.male, wasSpouse: _wasSpouse)
          .toLowerCase();
    }

    if (_bond == 'best friend') return 'best friend';

    if (_bond == 'friend' && widget.relationship.toLowerCase() == 'classmate') {
      return 'friend';
    }

    return widget.relationship;
  }

  void _interact(String action) {
    if (!widget.isAlive || _showingNarrative) return;

    if (action == 'Get Engaged' ||
        action == 'Get Married' ||
        action == 'Divorce') {
      _milestone(action);
      return;
    }

    _handle(
      action,
      widget.onInteraction(npcId: widget.npcId, action: action),
    );
  }

  void _handle(String action, Result<NpcInteractionOutcome> result) {
    switch (result) {
      case Success<NpcInteractionOutcome>(:final value):
        setState(() {
          _score = value.relationshipPercent;
          _bond = value.bond;
          _romance = value.romance;
          _stage = value.stage;
          _onPill = value.onBirthControl;
          if (action == 'Divorce') _wasSpouse = true;
          if (action == 'Argue') _hadArgument = true;
          if (action == 'Apologize') _hadArgument = false;
        });

        // Saying "not now" to a best friendship needs no story.
        if (action == NpcInteractionOutcome.bestFriendNo) return;

        setState(() => _showingNarrative = true);
        _showNarrative(
          value.narrative,
          progressed: value.progressed || value.refused,
          action: action,
        ).then((_) {
          if (!mounted) return;
          if (value.prompt == 'bestFriend') _askBestFriend();
          if (value.prompt == 'pregnancy') _askPregnancy();
        });
      case Failure<NpcInteractionOutcome>(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget? get _dialogAvatar => widget.avatar;

  /// The facts in the information overlay, with the marital status kept
  /// up to date after an engagement, a wedding or a divorce.
  List<MapEntry<String, String>> get _detailEntries {
    final entries = [...widget.details];
    final index = entries.indexWhere((entry) => entry.key == 'Marital Status');

    if (index < 0) return entries;

    final name = widget.playerName;

    if (_romance == 'partner' && name != null) {
      entries[index] = MapEntry(
        'Marital Status',
        switch (_stage) {
          LoveRules.stageMarried => 'Married to $name',
          LoveRules.stageEngaged => 'Engaged to $name',
          _ => 'Dating $name',
        },
      );

      if (_stage == LoveRules.stageMarried &&
          !entries.any((entry) => entry.key == 'Children')) {
        entries.insert(
          index + 1,
          MapEntry('Children', '${widget.childrenCount}'),
        );
      }
    } else if (_bond == 'ex') {
      entries[index] = MapEntry(
        'Marital Status',
        _wasSpouse ? 'Divorced' : 'Single',
      );
    }

    return entries;
  }

  /// Engagement, marriage and divorce: pop-ups first, then the result.
  Future<void> _milestone(String action) async {
    final milestones = widget.milestones;

    if (milestones == null) return;

    final id = widget.npcId;

    switch (action) {
      case 'Get Engaged':
        final ring = await showMilestoneChoice(
          context,
          title: 'PROPOSE',
          emoji: '💍',
          scene: milestones.scene('engage', id),
          options: LoveRules.rings,
          costLabel: milestones.costLabel,
          avatar: _dialogAvatar,
        );

        if (ring == null || !mounted) return;

        _handle(action, milestones.engage(npcId: id, ringId: ring));
      case 'Get Married':
        final prenup = await showMilestoneChoice(
          context,
          title: 'PRENUP',
          emoji: '📜',
          scene: milestones.scene('prenup', id),
          options: LoveRules.prenups,
          costLabel: milestones.costLabel,
          cancelLabel: 'NOT YET',
        );

        if (prenup == null || !mounted) return;

        final wedding = await showMilestoneChoice(
          context,
          title: 'WEDDING',
          emoji: '👰',
          scene: milestones.scene('wedding', id),
          options: LoveRules.weddings,
          costLabel: milestones.costLabel,
          cancelLabel: 'NOT YET',
          avatar: _dialogAvatar,
        );

        if (wedding == null || !mounted) return;

        _handle(
          action,
          milestones.marry(npcId: id, prenupId: prenup, weddingId: wedding),
        );
      default:
        final yes = await showMilestoneConfirm(
          context,
          title: 'DIVORCE',
          emoji: '📄',
          scene: milestones.scene('divorce', id),
          detail: milestones.divorcePreview(id),
          confirmLabel: 'FILE FOR DIVORCE',
          cancelLabel: 'KEEP TRYING',
        );

        if (!yes || !mounted) return;

        _handle(action, milestones.divorce(npcId: id));
    }
  }

  /// "Make this friend a best friend?" with a yes and a not now.
  Future<void> _askBestFriend() async {
    final theme = Theme.of(context);

    final yes = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) => ThemedDialog(
        title: 'BEST FRIEND?',
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            key: const Key('best-friend-prompt'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.avatar != null)
                Center(
                  child: SizedBox(
                    width: 84,
                    height: 105,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 112,
                        height: 140,
                        child: widget.avatar,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                '${widget.name} and I have grown really close. '
                'Do I want to make ${widget.name} my best friend?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              FilledButton(
                key: const Key('best-friend-yes'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('YES, BEST FRIENDS'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('best-friend-no'),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('NOT NOW'),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    _interact(
      yes == true
          ? NpcInteractionOutcome.bestFriendYes
          : NpcInteractionOutcome.bestFriendNo,
    );
  }

  /// "Keep the baby?" after a pregnancy.
  Future<void> _askPregnancy() async {
    final theme = Theme.of(context);

    final keep = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) => ThemedDialog(
        title: 'PREGNANCY',
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            key: const Key('pregnancy-prompt'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: Text('🤰', style: TextStyle(fontSize: 48))),
              const SizedBox(height: 10),
              Text(
                'A baby is on the way with ${widget.name}. '
                'Do we continue the pregnancy?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              FilledButton(
                key: const Key('pregnancy-keep'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('KEEP THE BABY'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('pregnancy-end'),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('END THE PREGNANCY'),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    _interact(
      keep == false
          ? NpcInteractionOutcome.pregnancyEnd
          : NpcInteractionOutcome.pregnancyKeep,
    );
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
    'Become Friends': ('🤝', 'Ask to be friends'),
    'Start Dating': ('💘', 'Ask them out'),
    'Go on a Date': ('🌹', 'Plan a date'),
    'Have Sex': ('🔥', 'Get intimate'),
    'Break Up': ('💔', 'End the relationship'),
    'Get Back Together': ('💞', 'Give us another chance'),
    'Get Engaged': ('💍', 'Propose'),
    'Get Married': ('👰', 'Plan the wedding'),
    'Divorce': ('📄', 'File for divorce'),
    'Birth Control': ('💊', 'Talk about birth control'),
    'Pregnancy: keep': ('👶', 'Keep the baby'),
    'Pregnancy: end': ('💔', 'End the pregnancy'),
    'Best Friend: yes': ('💛', 'Best friends'),
    'Talk': ('💬', 'Have a chat'),
    'Spend Time': ('🎈', 'Do something together'),
    'Play': ('🧸', 'Play together'),
    'Cry': ('😭', 'Cry for attention'),
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
        title: _relationshipLabel.toUpperCase(),
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
                      PipBar(
                        barKey: const Key('npc-details-relationship-bar'),
                        widthFactor: 0.5,
                        value: score.abs() / 100,
                      ),
                      const SizedBox(height: 6),
                      const SectionTitle('Basic Information'),
                      const SizedBox(height: 2),
                      ...withThinLines(context, [
                        if (age != null) InfoLine(label: 'Age', value: '$age'),
                        for (final entry in _detailEntries)
                          InfoLine(label: entry.key, value: entry.value),
                      ]),
                      if (widget.subtitle != null && _detailEntries.isEmpty)
                        Text(widget.subtitle!),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.traits != null) ...[
              const SizedBox(height: 8),
              const SectionTitle('Stats'),
              const SizedBox(height: 4),
              _traitRow(context, 'Looks', widget.traits!.looks),
              _traitRow(context, 'Smarts', widget.traits!.smarts),
              // Fertility is only shown once the person is an adult.
              if ((age ?? 0) >= LoveRules.adultAge)
                _traitRow(
                  context,
                  'Fertility',
                  widget.traits!.fertility,
                  key: const Key('npc-fertility-bar'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// One stat of the person: its name, a bar and the number.
  Widget _traitRow(BuildContext context, String label, int value, {Key? key}) {
    final theme = Theme.of(context);

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: PipBar(value: value / 100, height: 8)),
          SizedBox(
            width: 44,
            child: Text(
              '$value%',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  List<String> get _availableActions {
    final stage = LifeStageAge.fromAge(widget.playerAge.clamp(0, 150).toInt());
    final theirBirth = widget.birthYear;
    final thisYear = widget.currentYear;
    final theyAreBaby =
        theirBirth != null && thisYear != null && thisYear - theirBirth <= 2;

    // A baby can only play. A player who is a baby can only play and cry.
    if (theyAreBaby) return const ['Play'];

    if (stage == LifeStage.infant) return const ['Play', 'Cry'];

    // Friendship can be asked for once the relationship is good enough.
    final canBefriend = widget.befriendable &&
        _bond == 'none' &&
        _score >= SocialRules.friendAt;
    final birth = widget.birthYear;
    final year = widget.currentYear;
    final otherAge = birth != null && year != null ? year - birth : -1;
    final isPartner = _romance == 'partner';
    final canDate = widget.romanceEligible &&
        !isPartner &&
        !widget.playerHasPartner &&
        otherAge >= 0 &&
        LoveRules.canDate(widget.playerAge, otherAge) &&
        _score >= LoveRules.dateAt;
    final canBeIntimate =
        otherAge >= 0 && LoveRules.canBeIntimate(widget.playerAge, otherAge);
    final canGetBack = _bond == 'ex' &&
        !widget.playerHasPartner &&
        otherAge >= 0 &&
        LoveRules.canDate(widget.playerAge, otherAge) &&
        _score >= LoveRules.getBackAt;
    final love = [
      if (canDate) 'Start Dating',
      if (canGetBack) 'Get Back Together',
      if (isPartner) ...[
        'Go on a Date',
        if (canBeIntimate) 'Have Sex',
        if (widget.canUseBirthControl && canBeIntimate) 'Birth Control',
        if (_stage == LoveRules.stageDating &&
            widget.milestones?.canEngage(widget.npcId) == true)
          'Get Engaged',
        if (_stage == LoveRules.stageEngaged &&
            widget.milestones?.canMarry(widget.npcId) == true)
          'Get Married',
        if (_stage == LoveRules.stageMarried)
          'Divorce'
        else
          'Break Up',
      ],
    ];
    final basic = [
      'Talk',
      'Spend Time',
      'Compliment',
      'Help',
      if (canBefriend) 'Become Friends',
    ];
    if (stage == LifeStage.toddler || stage == LifeStage.child) {
      return basic;
    }
    return [...basic, ...love, 'Argue'];
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
              PageTopBar(
                title: _relationshipLabel,
                zoom: widget.zoom,
              ),
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
                        PipBar(value: score.abs() / 100, widthFactor: 0.5),
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
                    if (i > 0) const ThinLine(),
                    InteractionRow(
                      title: _availableActions[i],
                      emoji: _actionInfo[_availableActions[i]]?.$1 ?? '💬',
                      description: _availableActions[i] == 'Go on a Date' &&
                              !_bothAdults
                          ? 'Plan a date. Intimacy opens when we are both 18.'
                          : _availableActions[i] == 'Birth Control'
                          ? (_onPill
                              ? 'Stop using birth control'
                              : 'Start using birth control')
                          : _actionInfo[_availableActions[i]]?.$2 ?? '',
                      onPressed: widget.isAlive
                          ? () => _interact(_availableActions[i])
                          : null,
                    ),
                  ],
                  if (_hadArgument && widget.playerAge >= 13) ...[
                    const ThinLine(),
                    InteractionRow(
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
