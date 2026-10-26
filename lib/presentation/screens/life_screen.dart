
import 'package:flutter/material.dart';

import '../../data/services/character_palette_service.dart';
import '../../domain/character/character.dart';
import '../../domain/character/gender.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/family/sibling_npc.dart';
import '../widgets/character_avatar.dart';
import 'npc_interaction_screen.dart';

class LifeScreen extends StatelessWidget {
  const LifeScreen({
    required this.zoom,
    this.parents = const <ParentNpc>[],
    this.siblings = const <SiblingNpc>[],
    this.playerBirthYear = 2026,
    this.currentYear = 2026,
    super.key,
  });

  final double zoom;
  final List<ParentNpc> parents;
  final List<SiblingNpc> siblings;
  final int playerBirthYear;
  final int currentYear;

  @override
  Widget build(BuildContext context) {
    final visibleSiblings = siblings
        .where((sibling) => sibling.birthYear <= currentYear)
        .toList(growable: false);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(zoom),
      ),
      child: Scaffold(
        body: SafeArea(
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
                        _LifeHeader(zoom: zoom),
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
                                    currentYear: currentYear,
                                    zoom: zoom,
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
      ),
    );
  }
}

class _LifeHeader extends StatelessWidget {
  const _LifeHeader({
    required this.zoom,
  });

  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: s(4),
        vertical: s(2),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('life-back-button'),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          SizedBox(width: s(4)),
          Text(
            'Life',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
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
    double s(double value) => value * zoom;

    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(s(8)),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: s(2),
              bottom: s(2),
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: s(11),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ParentNpcCard extends StatelessWidget {
  const _ParentNpcCard({
    required this.parent,
    required this.currentYear,
    required this.zoom,
    super.key,
  });

  final ParentNpc parent;
  final int currentYear;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);

    final card = Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(s(8)),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
      ),
      child: InkWell(
        onTap: parent.isAlive ? () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NpcInteractionScreen(
              name: parent.fullName,
              relationship: _relationshipLabel(parent.role),
              relationshipPercent: parent.relationshipPercent,
            ),
          ),
        ) : null,
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
                      Expanded(
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
                        '(${_relationshipLabel(parent.role)})',
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
                      'Deceased'
                      '${parent.deathYear == null ? '' : ' · ${parent.deathYear}'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (parent.isAlive)
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
      ),
    );

    if (parent.isAlive) return card;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 18,
        0.2126, 0.7152, 0.0722, 0, 18,
        0.2126, 0.7152, 0.0722, 0, 18,
        0, 0, 0, 1, 0,
      ]),
      child: card,
    );
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
    super.key,
  });

  final SiblingNpc sibling;
  final int playerBirthYear;
  final int currentYear;
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

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(s(8)),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NpcInteractionScreen(
              name: sibling.fullName,
              relationship: '$ageLabel $siblingKind',
              relationshipPercent: sibling.relationshipPercent,
            ),
          ),
        ),
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
                    currentYear: currentYear,
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
                      Expanded(
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
                        '($ageLabel $siblingKind)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s(3)),
                  _RelationshipBar(value: sibling.relationshipPercent, zoom: zoom),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
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
    final positive = score > 0;
    final color = positive ? const Color(0xFF32CD62) : const Color(0xFFFF4545);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8 * zoom),
          child: LinearProgressIndicator(
            minHeight: 5 * zoom,
            value: score.abs() / 100.0,
            color: color,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
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
