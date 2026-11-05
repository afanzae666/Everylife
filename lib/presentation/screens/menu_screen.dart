
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: SafeArea(
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

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        leading: Icon(icon, size: 28),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
