import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.uiScaleController,
    required this.onUiScaleChanged,
    super.key,
  });

  final ValueNotifier<double> uiScaleController;

  final Future<void> Function(double value)
      onUiScaleChanged;

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
      builder: (
        context,
        zoom,
        _,
      ) {
        return _buildScaledPage(
          context,
          zoom,
        );
      },
    );
  }

  Widget _buildScaledPage(
    BuildContext context,
    double zoom,
  ) {
    final mediaQuery = MediaQuery.of(context);

    final scaledMediaQuery = mediaQuery.copyWith(
      textScaler: TextScaler.linear(zoom),
    );

    return MediaQuery(
      data: scaledMediaQuery,
      child: _buildScaffold(
        context,
        zoom,
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) => value * zoom;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          s(12),
          s(8),
          s(12),
          s(16),
        ),
        children: [
          Text(
            'Appearance',
            style: Theme.of(context)
                .textTheme
                .titleSmall,
          ),
          SizedBox(
            height: s(4),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: s(16),
                  ),
                  leading: Icon(
                    Icons.zoom_in_outlined,
                    size: s(24),
                  ),
                  title: const Text(
                    'UI Zoom',
                  ),
                  subtitle: Text(
                    '${(zoom * 100).round()}%',
                  ),
                ),
                Divider(
                  height: s(1),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    s(8),
                    s(4),
                    s(8),
                    s(8),
                  ),
                  child: Slider(
                    value: zoom,
                    min: zoomValues.first,
                    max: zoomValues.last,
                    divisions:
                        zoomValues.length - 1,
                    label:
                        '${(zoom * 100).round()}%',
                    onChanged: (value) {
                      final snapped =
                          _snapZoom(value);

                      uiScaleController.value =
                          snapped;

                      onUiScaleChanged(
                        snapped,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: s(12),
                  ),
                  child: Wrap(
                    spacing: s(4),
                    runSpacing: s(4),
                    children: [
                      for (final value
                          in zoomValues)
                        ChoiceChip(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal: s(8),
                            vertical: s(4),
                          ),
                          label: Text(
                            '${(value * 100).round()}%',
                          ),
                          selected:
                              (zoom - value)
                                      .abs() <
                                  0.001,
                          onSelected: (_) {
                            uiScaleController.value =
                                value;

                            onUiScaleChanged(
                              value,
                            );
                          },
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: s(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _snapZoom(
    double value,
  ) {
    var closest = zoomValues.first;

    var distance =
        (value - closest).abs();

    for (final candidate
        in zoomValues.skip(1)) {
      final candidateDistance =
          (value - candidate).abs();

      if (candidateDistance < distance) {
        closest = candidate;
        distance = candidateDistance;
      }
    }

    return closest;
  }
}
