
import 'package:flutter/material.dart';

import '../../app/theme/everylife_theme_mode_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.uiScaleController,
    required this.onUiScaleChanged,
    super.key,
  });

  final ValueNotifier<double> uiScaleController;

  final Future<void> Function(double value) onUiScaleChanged;

  static const List<double> zoomValues = [
    0.8,
    0.9,
    1.0,
    1.1,
    1.2,
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: uiScaleController,
      builder: (context, zoom, _) {
        final mediaQuery = MediaQuery.of(context);
        final scaledMediaQuery = mediaQuery.copyWith(
          textScaler: TextScaler.linear(zoom),
        );

        return MediaQuery(
          data: scaledMediaQuery,
          child: _buildScaffold(context, zoom),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, double zoom) {
    double s(double value) => value * zoom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          s(8),
          s(6),
          s(8),
          s(12),
        ),
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: s(2)),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: EveryLifeThemeModeController.mode,
                  builder: (context, themeMode, _) {
                    return SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: s(12),
                      ),
                      secondary: Icon(
                        Icons.dark_mode_outlined,
                        size: s(24),
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        themeMode == ThemeMode.dark
                            ? 'Dark Mode is on'
                            : 'Light Mode is on',
                      ),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (enabled) {
                        EveryLifeThemeModeController.updateMode(
                          enabled ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    );
                  },
                ),
                Divider(height: s(1)),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: s(12),
                  ),
                  leading: Icon(
                    Icons.zoom_in_outlined,
                    size: s(24),
                  ),
                  title: const Text('UI Zoom'),
                  subtitle: Text('${(zoom * 100).round()}%'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showUiZoomDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUiZoomDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ValueListenableBuilder<double>(
          valueListenable: uiScaleController,
          builder: (context, zoom, _) {
            final theme = Theme.of(context);

            return AlertDialog(
              title: const Text('UI Zoom'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(zoom * 100).round()}%',
                      style: theme.textTheme.headlineSmall,
                    ),
                    Slider(
                      value: zoom,
                      min: zoomValues.first,
                      max: zoomValues.last,
                      divisions: zoomValues.length - 1,
                      label: '${(zoom * 100).round()}%',
                      onChanged: (value) {
                        final snapped = _snapZoom(value);
                        uiScaleController.value = snapped;
                        onUiScaleChanged(snapped);
                      },
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final value in zoomValues)
                          ChoiceChip(
                            label: Text('${(value * 100).round()}%'),
                            selected: (zoom - value).abs() < 0.001,
                            onSelected: (_) {
                              uiScaleController.value = value;
                              onUiScaleChanged(value);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('DONE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _snapZoom(double value) {
    var closest = zoomValues.first;
    var distance = (value - closest).abs();

    for (final candidate in zoomValues.skip(1)) {
      final candidateDistance = (value - candidate).abs();

      if (candidateDistance < distance) {
        closest = candidate;
        distance = candidateDistance;
      }
    }

    return closest;
  }
}
