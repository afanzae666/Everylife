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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),
      body: ValueListenableBuilder<double>(
        valueListenable:
            uiScaleController,
        builder: (
          context,
          zoom,
          _,
        ) {
          final percent =
              (zoom * 100).round();

          return ListView(
            padding:
                const EdgeInsets.fromLTRB(
              12,
              8,
              12,
              16,
            ),
            children: [
              Text(
                'Appearance',
                style:
                    Theme.of(context)
                        .textTheme
                        .titleSmall,
              ),
              const SizedBox(
                height: 4,
              ),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.zoom_in_outlined,
                      ),
                      title: const Text(
                        'UI Zoom',
                      ),
                      subtitle: Text(
                        '$percent%',
                      ),
                    ),
                    const Divider(
                      height: 1,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        8,
                        4,
                        8,
                        8,
                      ),
                      child: Slider(
                        value: zoom,
                        min:
                            zoomValues.first,
                        max:
                            zoomValues.last,
                        divisions:
                            zoomValues.length -
                                1,
                        label: '$percent%',
                        onChanged: (value) {
                          final snapped =
                              _snapZoom(
                            value,
                          );

                          uiScaleController
                                  .value =
                              snapped;

                          onUiScaleChanged(
                            snapped,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                      ),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final value
                              in zoomValues)
                            ChoiceChip(
                              label: Text(
                                '${(value * 100).round()}%',
                              ),
                              selected:
                                  (zoom - value)
                                          .abs() <
                                      0.001,
                              onSelected:
                                  (_) {
                                uiScaleController
                                        .value =
                                    value;

                                onUiScaleChanged(
                                  value,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _snapZoom(
    double value,
  ) {
    var closest =
        zoomValues.first;

    var distance =
        (value - closest).abs();

    for (final candidate
        in zoomValues.skip(1)) {
      final candidateDistance =
          (value - candidate).abs();

      if (candidateDistance <
          distance) {
        closest = candidate;
        distance =
            candidateDistance;
      }
    }

    return closest;
  }
}
