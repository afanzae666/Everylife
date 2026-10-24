
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
    double s(double value) => value * zoom;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(zoom),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Life'),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              s(8),
              s(6),
              s(8),
              s(12),
            ),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(s(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Life',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: s(1)),
                      Text(
                        'The people and relationships in your life.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: s(4)),
                      Text(
                        'Parents',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (parents.isEmpty)
                        const ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.family_restroom_outlined,
                          ),
                          subtitle: Text(
                            'Family details are not available in this save.',
                          ),
                        )
                      else
                        ...parents.map(
                          (parent) => Padding(
                            key: ValueKey('parent-${parent.id}'),
                            padding: EdgeInsets.symmetric(
                              vertical: s(4),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _ParentAvatar(
                                  parent: parent,
                                  currentYear: currentYear,
                                  size: s(64),
                                ),
                                SizedBox(width: s(10)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        parent.fullName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      SizedBox(height: s(3)),
                                      Text(
                                        parent.isAlive
                                            ? (parent.occupation ??
                                                parent.employmentStatus.name)
                                            : 'Deceased${parent.deathYear == null ? '' : ' · ${parent.deathYear}'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const _LifeContainerItem(
                        icon: Icons.people_outline,
                        title: 'Friends',
                      ),
                      const _LifeContainerItem(
                        icon: Icons.favorite_border,
                        title: 'Partner',
                      ),
                      const _LifeContainerItem(
                        icon: Icons.child_care_outlined,
                        title: 'Children',
                      ),
                      const _LifeContainerItem(
                        icon: Icons.people_alt_outlined,
                        title: 'Relationships',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

class _LifeContainerItem extends StatelessWidget {
  const _LifeContainerItem({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: const Text('Future life system'),
    );
  }
}
