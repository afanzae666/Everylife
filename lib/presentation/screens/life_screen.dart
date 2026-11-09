
import 'package:everylife/presentation/widgets/page_top_bar.dart';
import 'package:flutter/material.dart';

import '../../data/services/character_palette_service.dart';
import '../../domain/character/character.dart';
import '../../domain/character/gender.dart';
import '../../core/result/result.dart';
import '../../domain/event/npc_interaction_outcome.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/world/country_catalog.dart';
import '../../domain/family/sibling_npc.dart';
import '../../domain/career/school_npc.dart';
import '../../domain/character/fertility.dart';
import '../../domain/love/love_state.dart';
import '../../simulation/school/school_appearance.dart';
import '../widgets/npc_avatar.dart';
import '../widgets/themed_cards.dart';
import '../widgets/character_avatar.dart';
import 'npc_interaction_screen.dart';
import '../../simulation/generation/npc_wealth.dart';
import '../widgets/npc_money.dart';


String _parentDetails(ParentNpc parent) {
  final employment = switch (parent.employmentStatus) {
    EmploymentStatus.employed => parent.occupation ?? 'Employed',
    EmploymentStatus.selfEmployed => parent.occupation ?? 'Self-employed',
    EmploymentStatus.unemployed => 'Unemployed',
    EmploymentStatus.retired => 'Retired',
    EmploymentStatus.homemaker => 'Homemaker',
    EmploymentStatus.unableToWork => 'Unable to work',
  };
  return '$employment · ${parent.countryCode}'
      '${parent.isAlive ? '' : ' · ${_deceasedLabel(parent.birthYear, parent.deathYear)}'}';
}

String _genderLabel(Gender gender) => gender == Gender.male ? 'Male' : 'Female';

String _countryLabel(String countryCode) {
  return CountryCatalog.findByCode(countryCode)?.name ?? countryCode;
}

/// Facts shown in the parent information overlay (after Age).
List<MapEntry<String, String>> _parentDetailList(ParentNpc parent) {
  final occupation = switch (parent.employmentStatus) {
    EmploymentStatus.employed => parent.occupation ?? 'Employed',
    EmploymentStatus.selfEmployed => parent.occupation ?? 'Self-employed',
    EmploymentStatus.unemployed => 'Unemployed',
    EmploymentStatus.retired => 'Retired',
    EmploymentStatus.homemaker => 'Homemaker',
    EmploymentStatus.unableToWork => 'Unable to work',
  };

  return [
    MapEntry('Gender', _genderLabel(parent.gender)),
    MapEntry('Occupation', occupation),
    MapEntry('Location', _countryLabel(parent.countryCode)),
  ];
}

/// Facts shown in the sibling information overlay (after Age).
List<MapEntry<String, String>> _siblingDetailList(
  SiblingNpc sibling,
  String kind,
) {
  final finance = sibling.finance;
  final job = finance?.jobId == null ? null : JobCatalog.byId(finance!.jobId!);

  return [
    MapEntry('Gender', _genderLabel(sibling.gender)),
    if (finance != null)
      MapEntry('Occupation', job?.titleAt(finance.rank) ?? 'Unemployed'),
    MapEntry('Location', _countryLabel(sibling.countryCode)),
  ];
}

/// "Deceased · age 63". Years are never shown, only the age at death.
String _passedAwayLabel(int birthYear, int? deathYear) {
  if (deathYear == null) return '🕊️ Passed away';

  return '🕊️ Passed away at age ${(deathYear - birthYear).clamp(0, 150)}';
}

String _deceasedLabel(int birthYear, int? deathYear) {
  if (deathYear == null) return 'Deceased';

  return 'Deceased · age ${(deathYear - birthYear).clamp(0, 150)}';
}

Result<NpcInteractionOutcome> _noNpcInteraction({required String npcId, required String action}) =>
    const Failure('NPC interaction is unavailable outside the active simulation.');

class LifeScreen extends StatefulWidget {
  const LifeScreen({
    required this.zoom,
    this.parents = const <ParentNpc>[],
    this.siblings = const <SiblingNpc>[],
    this.playerBirthYear = 2026,
    this.currentYear = 2026,
    this.onNpcInteraction = _noNpcInteraction,
    this.readCurrentParents,
    this.readCurrentSiblings,
    this.headerBuilder,
    this.friends = const <SchoolNpc>[],
    this.readCurrentFriends,
    this.love = const LoveState(),
    this.readCurrentLove,
    super.key,
  });

  final double zoom;
  final List<ParentNpc> parents;
  final List<SiblingNpc> siblings;
  final int playerBirthYear;
  final int currentYear;
  final Result<NpcInteractionOutcome> Function({required String npcId, required String action}) onNpcInteraction;
  final List<ParentNpc> Function()? readCurrentParents;

  final List<SiblingNpc> Function()? readCurrentSiblings;

  /// Builds the character card shown at the top of the page.
  final WidgetBuilder? headerBuilder;

  /// Friends the player made. They are shown under the siblings.
  final List<SchoolNpc> friends;
  final List<SchoolNpc> Function()? readCurrentFriends;

  /// Partner and children. Shown above the parents.
  final LoveState love;
  final LoveState Function()? readCurrentLove;

  @override
  State<LifeScreen> createState() => _LifeScreenState();
}

class _LifeScreenState extends State<LifeScreen> {
  late List<ParentNpc> _parents = widget.parents;
  late List<SiblingNpc> _siblings = widget.siblings;
  late List<SchoolNpc> _friends = widget.friends;
  late LoveState _love = widget.love;

  void _refreshNpcData() {
    if (!mounted) return;
    setState(() {
      _parents = widget.readCurrentParents?.call() ?? _parents;
      _siblings = widget.readCurrentSiblings?.call() ?? _siblings;
      _friends = widget.readCurrentFriends?.call() ?? _friends;
      _love = widget.readCurrentLove?.call() ?? _love;
    });
  }

  @override
  void didUpdateWidget(covariant LifeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.parents, widget.parents)) _parents = widget.parents;
    if (!identical(oldWidget.siblings, widget.siblings)) _siblings = widget.siblings;
    if (!identical(oldWidget.friends, widget.friends)) _friends = widget.friends;
    if (!identical(oldWidget.love, widget.love)) _love = widget.love;
  }

  @override
  Widget build(BuildContext context) {
    final zoom = widget.zoom;
    final parents = _parents;
    final currentYear = widget.currentYear;
    final playerBirthYear = widget.playerBirthYear;
    final onNpcInteraction = widget.onNpcInteraction;
    final partner = _love.partnerId == null
        ? null
        : _friends.where((f) => f.id == _love.partnerId).firstOrNull;
    final otherFriends = [
      for (final friend in _friends)
        if (friend.id != _love.partnerId) friend,
    ];
    final visibleSiblings = _siblings
        .where((sibling) => sibling.birthYear <= currentYear)
        .toList(growable: false);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // The character card stays fixed at the top of the page.
              if (widget.headerBuilder != null) widget.headerBuilder!(context),
              PageTopBar(
                title: 'Life',
                zoom: zoom,
                backKey: const Key('life-back-button'),
              ),
              Expanded(
                child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (partner != null || _love.pregnancy != null)
                          _CategoryCard(
                            title: 'Love',
                            zoom: zoom,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (partner != null)
                                  _FriendNpcCard(
                                    key: ValueKey('partner-card-${partner.id}'),
                                    friend: partner,
                                    isPartner: true,
                                    hasPartner: true,
                                    onBirthControl: _love.birthControl
                                        .contains(partner.id),
                                    playerBirthYear: playerBirthYear,
                                    currentYear: currentYear,
                                    zoom: zoom,
                                    onNpcInteraction: onNpcInteraction,
                                    onInteractionPageClosed: _refreshNpcData,
                                    headerBuilder: widget.headerBuilder,
                                  ),
                                if (_love.pregnancy != null)
                                  Padding(
                                    key: const Key('pregnancy-note'),
                                    padding: EdgeInsets.all(zoom * 6),
                                    child: Text(
                                      'A baby is on the way. The birth is at '
                                      'the next birthday.',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (_love.children.isNotEmpty)
                          _CategoryCard(
                            title: 'Children',
                            zoom: zoom,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final child in _love.children)
                                  _ChildNpcCard(
                                    key: ValueKey('child-card-${child.id}'),
                                    child: child,
                                    playerBirthYear: playerBirthYear,
                                    currentYear: currentYear,
                                    zoom: zoom,
                                    onNpcInteraction: onNpcInteraction,
                                    onInteractionPageClosed: _refreshNpcData,
                                    headerBuilder: widget.headerBuilder,
                                  ),
                              ],
                            ),
                          ),
                        if (parents.isNotEmpty)
                          _CategoryCard(
                            title: 'Parents',
                            zoom: zoom,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final parent in parents)
                                  _ParentNpcCard(
                                    key: ValueKey('parent-card-${parent.id}'),
                                    parent: parent,
                                    playerBirthYear: playerBirthYear,
                                    currentYear: currentYear,
                                    zoom: zoom,
                                    onNpcInteraction: onNpcInteraction,
                                    onInteractionPageClosed: _refreshNpcData,
                                    headerBuilder: widget.headerBuilder,
                                  ),
                              ],
                            ),
                          ),
                        if (visibleSiblings.isNotEmpty)
                          _CategoryCard(
                            title: 'Siblings',
                            zoom: zoom,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final sibling in visibleSiblings)
                                  _SiblingNpcCard(
                                    key: ValueKey('sibling-card-${sibling.id}'),
                                    sibling: sibling,
                                    playerBirthYear: playerBirthYear,
                                    currentYear: currentYear,
                                    zoom: zoom,
                                    onNpcInteraction: onNpcInteraction,
                                    onInteractionPageClosed: _refreshNpcData,
                                    headerBuilder: widget.headerBuilder,
                                  ),
                              ],
                            ),
                          ),
                        if (otherFriends.isNotEmpty)
                          _CategoryCard(
                            title: 'Friends',
                            zoom: zoom,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final friend in otherFriends)
                                  _FriendNpcCard(
                                    hasPartner: _love.hasPartner,
                                    key: ValueKey('friend-card-${friend.id}'),
                                    friend: friend,
                                    playerBirthYear: playerBirthYear,
                                    currentYear: currentYear,
                                    zoom: zoom,
                                    onNpcInteraction: onNpcInteraction,
                                    onInteractionPageClosed: _refreshNpcData,
                                    headerBuilder: widget.headerBuilder,
                                  ),
                              ],
                            ),
                          ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.zoom,
    required this.child,
  });

  final String title;
  final double zoom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionDivider(title: title, zoom: zoom),
          child,
        ],
      ),
    );
  }
}

class _ParentNpcCard extends StatelessWidget {
  const _ParentNpcCard({
    required this.parent,
    required this.playerBirthYear,
    required this.currentYear,
    required this.zoom,
    required this.onNpcInteraction,
    required this.onInteractionPageClosed,
    this.headerBuilder,
    super.key,
  });

  final WidgetBuilder? headerBuilder;
  final VoidCallback onInteractionPageClosed;
  final ParentNpc parent;
  final int playerBirthYear;
  final int currentYear;
  final Result<NpcInteractionOutcome> Function({required String npcId, required String action}) onNpcInteraction;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);

    final card = AccentCard(
      zoom: zoom,
      child: InkWell(
        onTap: parent.isAlive ? () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => NpcInteractionScreen(
              npcId: parent.id,
              name: parent.fullName,
              onInteraction: onNpcInteraction,
              relationship: _relationshipLabel(parent.role),
              relationshipPercent: parent.relationshipPercent,
              playerAge: currentYear - playerBirthYear,
              currentYear: currentYear,
              birthYear: parent.birthYear,
              subtitle: _parentDetails(parent),
              details: _parentDetailList(parent),
              netWorth: npcMoneyLabel(
                NpcWealth.forParent(parent),
                parent.countryCode,
              ),
              countryCode: parent.countryCode,
              traits: NpcTraits.forPerson(
                id: parent.id,
                gender: parent.gender,
                birthYear: parent.birthYear,
                currentYear: currentYear,
              ),
              zoom: zoom,
              headerBuilder: headerBuilder,
              avatar: _ParentAvatar(
                parent: parent,
                currentYear: currentYear,
                size: 112,
              ),
            ),
          ),
        ).then((_) => onInteractionPageClosed()) : null,
        child: Padding(
        padding: EdgeInsets.all(s(3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ParentAvatar(
              parent: parent,
              currentYear: currentYear,
              size: s(56),
            ),
            SizedBox(width: s(6)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          parent.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: s(4)),
                      Text(
                        '(${_relationshipLabel(parent.role).toUpperCase()})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s(3)),
                  _RelationshipBar(value: parent.relationshipPercent, zoom: zoom),
                  if (!parent.isAlive) ...[
                    SizedBox(height: s(2)),
                    Text(
                      _passedAwayLabel(parent.birthYear, parent.deathYear),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (parent.isAlive) ChevronBadge(zoom: zoom),
          ],
        ),
      ),
      ),
    );

    return parent.isAlive ? card : Opacity(opacity: 0.55, child: card);
  }

  String _relationshipLabel(FamilyRole role) {
    switch (role) {
      case FamilyRole.father:
        return 'father';
      case FamilyRole.mother:
        return 'mother';
      case FamilyRole.guardian:
        return 'guardian';
      case FamilyRole.stepFather:
        return 'stepfather';
      case FamilyRole.stepMother:
        return 'stepmother';
    }
  }
}

class _SiblingNpcCard extends StatelessWidget {
  const _SiblingNpcCard({
    required this.sibling,
    required this.playerBirthYear,
    required this.currentYear,
    required this.zoom,
    required this.onNpcInteraction,
    required this.onInteractionPageClosed,
    this.headerBuilder,
    super.key,
  });

  final WidgetBuilder? headerBuilder;
  final VoidCallback onInteractionPageClosed;
  final SiblingNpc sibling;
  final int playerBirthYear;
  final int currentYear;
  final Result<NpcInteractionOutcome> Function({required String npcId, required String action}) onNpcInteraction;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);
    final older = sibling.isOlderThan(playerBirthYear);

    final siblingKind = switch (sibling.relationship) {
      SiblingRelationship.fullSibling =>
        sibling.gender == Gender.male ? 'brother' : 'sister',
      SiblingRelationship.halfSibling =>
        sibling.gender == Gender.male ? 'half-brother' : 'half-sister',
      SiblingRelationship.stepSibling =>
        sibling.gender == Gender.male ? 'stepbrother' : 'stepsister',
    };

    final ageLabel = older ? 'older' : 'younger';

    final card = AccentCard(
      zoom: zoom,
      child: InkWell(
        onTap: sibling.isAlive ? () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => NpcInteractionScreen(
              npcId: sibling.id,
              name: sibling.fullName,
              onInteraction: onNpcInteraction,
              relationship: '$ageLabel $siblingKind',
              relationshipPercent: sibling.relationshipPercent,
              playerAge: currentYear - playerBirthYear,
              currentYear: currentYear,
              birthYear: sibling.birthYear,
              subtitle: 'Sibling · ${sibling.relationship.name}',
              details: _siblingDetailList(sibling, siblingKind),
              netWorth: npcMoneyLabel(
                NpcWealth.forSibling(sibling),
                sibling.countryCode,
              ),
              countryCode: sibling.countryCode,
              traits: NpcTraits.forPerson(
                id: sibling.id,
                gender: sibling.gender,
                birthYear: sibling.birthYear,
                currentYear: currentYear,
              ),
              zoom: zoom,
              headerBuilder: headerBuilder,
              avatar: SizedBox(
                width: 112,
                height: 140,
                child: _SiblingAvatarForProfile(
                  sibling: sibling,
                  currentYear: currentYear,
                  size: 112,
                ),
              ),
            ),
          ),
        ).then((_) => onInteractionPageClosed()) : null,
        child: Padding(
        padding: EdgeInsets.all(s(3)),
        child: Row(
          children: [
            SizedBox(
              width: s(56),
              height: s(70),
              child: FutureBuilder<CharacterPaletteService>(
                future: CharacterPaletteService.load(),
                builder: (context, snapshot) {
                  final palette = snapshot.data;

                  if (snapshot.connectionState != ConnectionState.done ||
                      snapshot.hasError ||
                      palette == null) {
                    return Center(
                      child: CircleAvatar(
                        radius: s(18),
                        child: const Icon(Icons.person_outline),
                      ),
                    );
                  }

                  if (sibling.birthYear > currentYear) {
                    return Center(
                      child: CircleAvatar(
                        radius: s(18),
                        child: const Icon(Icons.person_outline),
                      ),
                    );
                  }

                  final character = Character.create(
                    id: sibling.id,
                    firstName: sibling.firstName,
                    lastName: sibling.lastName,
                    gender: sibling.gender,
                    birthYear: sibling.birthYear,
                    appearance: sibling.appearance,
                  );

                  final skinColor =
                      palette.skinColor(sibling.appearance.skinTone);
                  final eyeColor =
                      palette.eyeColor(sibling.appearance.eyeColor);
                  final hairColor =
                      palette.hairColor(sibling.appearance.hairColor);

                  if (skinColor == null ||
                      eyeColor == null ||
                      hairColor == null) {
                    return Center(
                      child: CircleAvatar(
                        radius: s(18),
                        child: const Icon(Icons.person_outline),
                      ),
                    );
                  }

                  return CharacterAvatar(
                    character: character,
                    currentYear: sibling.isAlive ? currentYear : (sibling.deathYear ?? currentYear),
                    size: s(56),
                    skinColor: skinColor,
                    eyeColor: eyeColor,
                    hairColor: hairColor,
                  );
                },
              ),
            ),
            SizedBox(width: s(6)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          sibling.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: s(4)),
                      Text(
                        '(${'$ageLabel $siblingKind'.toUpperCase()})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s(3)),
                  _RelationshipBar(value: sibling.relationshipPercent, zoom: zoom),
                  if (!sibling.isAlive) ...[
                    SizedBox(height: s(2)),
                    Text(
                      _passedAwayLabel(sibling.birthYear, sibling.deathYear),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (sibling.isAlive) ChevronBadge(zoom: zoom),
          ],
        ),
      ),
      ),
    );

    return sibling.isAlive ? card : Opacity(opacity: 0.55, child: card);
  }
}


class _FriendNpcCard extends StatelessWidget {
  const _FriendNpcCard({
    required this.friend,
    required this.playerBirthYear,
    required this.currentYear,
    required this.zoom,
    required this.onNpcInteraction,
    required this.onInteractionPageClosed,
    this.headerBuilder,
    this.isPartner = false,
    this.hasPartner = false,
    this.onBirthControl = false,
    super.key,
  });

  final bool onBirthControl;
  final bool isPartner;
  final bool hasPartner;
  final WidgetBuilder? headerBuilder;
  final VoidCallback onInteractionPageClosed;
  final SchoolNpc friend;
  final int playerBirthYear;
  final int currentYear;
  final Result<NpcInteractionOutcome> Function({required String npcId, required String action}) onNpcInteraction;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);
    final age = currentYear - friend.birthYear;

    return AccentCard(
      zoom: zoom,
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push<void>(
              MaterialPageRoute<void>(
                builder: (_) => NpcInteractionScreen(
                  npcId: friend.id,
                  name: friend.fullName,
                  onInteraction: onNpcInteraction,
                  relationship: isPartner ? 'partner' : 'friend',
                  relationshipPercent: friend.relationshipPercent,
                  playerAge: currentYear - playerBirthYear,
                  currentYear: currentYear,
                  birthYear: friend.birthYear,
                  subtitle: isPartner ? 'Partner' : 'Friend',
                  details: [
                    MapEntry('Gender', _genderLabel(friend.gender)),
                    MapEntry(
                      'Occupation',
                      age < 23 ? 'Student' : 'Working adult',
                    ),
                    MapEntry('Location', _countryLabel(friend.countryCode)),
                  ],
                  netWorth: npcMoneyLabel(
                    NpcWealth.forSchoolNpc(friend),
                    friend.countryCode,
                  ),
                  countryCode: friend.countryCode,
                  traits: NpcTraits.forPerson(
                    id: friend.id,
                    gender: friend.gender,
                    birthYear: friend.birthYear,
                    currentYear: currentYear,
                  ),
                  bond: friend.bestFriend ? 'best friend' : 'friend',
                  romanceEligible: friend.role.isStudent,
                  romance: isPartner ? 'partner' : 'none',
                  playerHasPartner: hasPartner,
                  canUseBirthControl:
                      isPartner && friend.gender == Gender.female,
                  onBirthControl: onBirthControl,
                  zoom: zoom,
                  headerBuilder: headerBuilder,
                  avatar: NpcAvatar(
                    character: SchoolAppearance.characterFor(friend),
                    currentYear: currentYear,
                    size: 112,
                  ),
                ),
              ),
            )
            .then((_) => onInteractionPageClosed()),
        child: Padding(
          padding: EdgeInsets.all(s(3)),
          child: Row(
            children: [
              NpcAvatar(
                character: SchoolAppearance.characterFor(friend),
                currentYear: currentYear,
                size: s(56),
              ),
              SizedBox(width: s(6)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            friend.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: s(4)),
                        Text(
                          isPartner
                              ? '(PARTNER)'
                              : friend.bestFriend
                                  ? '(BEST FRIEND)'
                                  : '(FRIEND)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: s(3)),
                    _RelationshipBar(
                      value: friend.relationshipPercent,
                      zoom: zoom,
                    ),
                  ],
                ),
              ),
              ChevronBadge(zoom: zoom),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildNpcCard extends StatelessWidget {
  const _ChildNpcCard({
    required this.child,
    required this.playerBirthYear,
    required this.currentYear,
    required this.zoom,
    required this.onNpcInteraction,
    required this.onInteractionPageClosed,
    this.headerBuilder,
    super.key,
  });

  final WidgetBuilder? headerBuilder;
  final VoidCallback onInteractionPageClosed;
  final ChildNpc child;
  final int playerBirthYear;
  final int currentYear;
  final Result<NpcInteractionOutcome> Function({required String npcId, required String action}) onNpcInteraction;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);
    final age = currentYear - child.birthYear;
    final label = child.gender == Gender.female ? 'Daughter' : 'Son';

    return AccentCard(
      zoom: zoom,
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push<void>(
              MaterialPageRoute<void>(
                builder: (_) => NpcInteractionScreen(
                  npcId: child.id,
                  name: child.fullName,
                  onInteraction: onNpcInteraction,
                  relationship: label.toLowerCase(),
                  relationshipPercent: child.relationshipPercent,
                  playerAge: currentYear - playerBirthYear,
                  currentYear: currentYear,
                  birthYear: child.birthYear,
                  subtitle: label,
                  details: [
                    MapEntry('Gender', _genderLabel(child.gender)),
                    MapEntry('Age', '$age'),
                    if (child.otherParentName.isNotEmpty)
                      MapEntry('Other parent', child.otherParentName),
                    MapEntry('Location', _countryLabel(child.countryCode)),
                  ],
                  countryCode: child.countryCode,
                  traits: NpcTraits(
                    looks: child.looks,
                    smarts: child.smarts,
                    fertility: Fertility.effective(
                      child.fertilityBase,
                      age,
                      child.gender,
                    ),
                    fertilityBase: child.fertilityBase,
                  ),
                  bond: 'child',
                  zoom: zoom,
                  headerBuilder: headerBuilder,
                  avatar: NpcAvatar(
                    character: SchoolAppearance.characterForChild(child),
                    currentYear: currentYear,
                    size: 112,
                  ),
                ),
              ),
            )
            .then((_) => onInteractionPageClosed()),
        child: Padding(
          padding: EdgeInsets.all(s(3)),
          child: Row(
            children: [
              NpcAvatar(
                character: SchoolAppearance.characterForChild(child),
                currentYear: currentYear,
                size: s(56),
              ),
              SizedBox(width: s(6)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            child.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: s(4)),
                        Text(
                          '(${label.toUpperCase()})',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: s(3)),
                    _RelationshipBar(
                      value: child.relationshipPercent,
                      zoom: zoom,
                    ),
                  ],
                ),
              ),
              ChevronBadge(zoom: zoom),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelationshipBar extends StatelessWidget {
  const _RelationshipBar({required this.value, required this.zoom});

  final int value;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final score = value.clamp(-100, 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PipBar(value: score.abs() / 100.0, widthFactor: 0.5),
        SizedBox(height: 1 * zoom),
        Text(
          'Relationship · $score%',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _ParentAvatar extends StatelessWidget {
  const _ParentAvatar({
    required this.parent,
    required this.currentYear,
    required this.size,
  });

  final ParentNpc parent;
  final int currentYear;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = SizedBox(
      width: size,
      height: size * 1.25,
      child: Center(
        child: CircleAvatar(
          radius: size * 0.35,
          child: Icon(
            parent.isAlive
                ? Icons.person_outline
                : Icons.person_off_outlined,
          ),
        ),
      ),
    );

    return SizedBox(
      width: size,
      height: size * 1.25,
      child: FutureBuilder<CharacterPaletteService>(
        future: CharacterPaletteService.load(),
        builder: (context, snapshot) {
          final palette = snapshot.data;

          if (snapshot.connectionState != ConnectionState.done ||
              snapshot.hasError ||
              palette == null) {
            return fallback;
          }

          final character = Character.create(
            id: parent.id,
            firstName: parent.firstName,
            lastName: parent.lastName,
            gender: parent.gender,
            birthYear: parent.birthYear,
            appearance: parent.appearance,
          );

          final skinColor = palette.skinColor(
            parent.appearance.skinTone,
          );
          final eyeColor = palette.eyeColor(
            parent.appearance.eyeColor,
          );
          final hairColor = palette.hairColor(
            parent.appearance.hairColor,
          );

          if (skinColor == null ||
              eyeColor == null ||
              hairColor == null) {
            return fallback;
          }

          final avatar = CharacterAvatar(
            character: character,
            currentYear: parent.isAlive
                ? currentYear
                : (parent.deathYear ?? currentYear),
            size: size,
            skinColor: skinColor,
            eyeColor: eyeColor,
            hairColor: hairColor,
          );
          return avatar;
        },
      ),
    );
  }
}

class _SiblingAvatarForProfile extends StatelessWidget {
  const _SiblingAvatarForProfile({
    required this.sibling,
    required this.currentYear,
    required this.size,
  });

  final SiblingNpc sibling;
  final int currentYear;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CharacterPaletteService>(
      future: CharacterPaletteService.load(),
      builder: (context, snapshot) {
        final palette = snapshot.data;
        if (palette == null || snapshot.hasError ||
            snapshot.connectionState != ConnectionState.done) {
          return const Icon(Icons.person_outline, size: 64);
        }
        final skin = palette.skinColor(sibling.appearance.skinTone);
        final eyes = palette.eyeColor(sibling.appearance.eyeColor);
        final hair = palette.hairColor(sibling.appearance.hairColor);
        if (skin == null || eyes == null || hair == null) {
          return const Icon(Icons.person_outline, size: 64);
        }
        return CharacterAvatar(
          character: Character.create(
            id: sibling.id,
            firstName: sibling.firstName,
            lastName: sibling.lastName,
            gender: sibling.gender,
            birthYear: sibling.birthYear,
            appearance: sibling.appearance,
          ),
          currentYear: currentYear,
          size: size,
          skinColor: skin,
          eyeColor: eyes,
          hairColor: hair,
        );
      },
    );
  }
}
