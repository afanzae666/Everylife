
import 'package:flutter/material.dart';

import '../../data/services/character_palette_service.dart';
import '../../domain/character/character.dart';
import '../../domain/family/parent_npc.dart';
import '../widgets/character_avatar.dart';

class LifeScreen extends StatelessWidget {
  const LifeScreen({
    required this.zoom,
    this.parents = const <ParentNpc>[],
    this.currentYear = 2026,
    super.key,
  });

  final double zoom;
  final List<ParentNpc> parents;
  final int currentYear;

  @override
  Widget build(BuildContext context) {
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
                        _CategoryCard(
                          title: 'Love',
                          icon: Icons.favorite_border,
                          zoom: zoom,
                          child: const _CategoryPlaceholder(
                            message: 'No partner to show yet.',
                          ),
                        ),
                        _CategoryCard(
                          title: 'Children',
                          icon: Icons.child_care_outlined,
                          zoom: zoom,
                          child: const _CategoryPlaceholder(
                            message: 'No children to show yet.',
                          ),
                        ),
                        _CategoryCard(
                          title: 'Parents',
                          icon: Icons.family_restroom_outlined,
                          zoom: zoom,
                          child: parents.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    'Family details are not available '
                                    'in this save.',
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (var i = 0;
                                        i < parents.length;
                                        i++)
                                      _ParentNpcCard(
                                        key: ValueKey(
                                          'parent-card-${parents[i].id}',
                                        ),
                                        parent: parents[i],
                                        currentYear: currentYear,
                                        zoom: zoom,
                                      ),
                                  ],
                                ),
                        ),
                        _CategoryCard(
                          title: 'Friends',
                          icon: Icons.people_outline,
                          zoom: zoom,
                          child: const _CategoryPlaceholder(
                            message: 'No friends to show yet.',
                          ),
                        ),
                        _CategoryCard(
                          title: 'Enemies',
                          icon: Icons.person_off_outlined,
                          zoom: zoom,
                          child: const _CategoryPlaceholder(
                            message: 'No enemies to show yet.',
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

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: s(8),
          vertical: s(4),
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
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.zoom,
    required this.child,
  });

  final String title;
  final IconData icon;
  final double zoom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(s(8)),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(s(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: s(20),
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: s(7)),
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: s(2)),
            child,
          ],
        ),
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
      child: Padding(
        padding: EdgeInsets.all(s(8)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ParentAvatar(
              parent: parent,
              currentYear: currentYear,
              size: s(76),
            ),
            SizedBox(width: s(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _relationshipLabel(parent.role),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: s(2)),
                  Text(
                    parent.fullName,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (!parent.isAlive) ...[
                    SizedBox(height: s(3)),
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
          ],
        ),
      ),
    );
  }

  String _relationshipLabel(FamilyRole role) {
    switch (role) {
      case FamilyRole.father:
        return 'Father';
      case FamilyRole.mother:
        return 'Mother';
      case FamilyRole.guardian:
        return 'Guardian';
    }
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

          return CharacterAvatar(
            character: character,
            currentYear: currentYear,
            size: size,
            skinColor: skinColor,
            eyeColor: eyeColor,
            hairColor: hairColor,
          );
        },
      ),
    );
  }
}

class _CategoryPlaceholder extends StatelessWidget {
  const _CategoryPlaceholder({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
