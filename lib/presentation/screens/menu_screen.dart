
import 'package:flutter/material.dart';

import '../widgets/page_top_bar.dart';
import '../widgets/themed_cards.dart';

enum MenuScreenAction {
  newLife,
  lifeStorage,
  settings,
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({
    required this.zoom,
    super.key,
  });

  final double zoom;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageTopBar(title: 'Menu', zoom: zoom),
            Expanded(
              child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _MenuOption(
              icon: Icons.add_circle_outline,
              title: 'New Life',
              description:
                  'Start a new life with a new character.',
              onTap: () {
                Navigator.of(context).pop(
                  MenuScreenAction.newLife,
                );
              },
            ),
            _MenuOption(
              icon: Icons.inventory_2_outlined,
              title: 'Life Storage',
              description:
                  'Every life saves automatically. Switch between lives.',
              onTap: () {
                Navigator.of(context).pop(
                  MenuScreenAction.lifeStorage,
                );
              },
            ),
            _MenuOption(
              icon: Icons.settings_outlined,
              title: 'Settings',
              description:
                  'Customize your game preferences.',
              onTap: () {
                Navigator.of(context).pop(
                  MenuScreenAction.settings,
                );
              },
            ),
          ],
        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;

    return AccentCard(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primary, width: 1.5),
                ),
                child: Icon(icon, size: 26, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
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
