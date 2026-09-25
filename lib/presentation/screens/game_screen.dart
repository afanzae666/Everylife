import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/character/gender.dart';
import '../../domain/character/life_stage.dart';
import '../../simulation/engine/simulation_engine.dart';
import 'character_profile_screen.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.engine,
    this.uiScaleController,
    super.key,
  });

  final SimulationEngine engine;
  final ValueNotifier<double>? uiScaleController;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  SimulationEngine get engine => widget.engine;

  late final ValueNotifier<double> _uiScaleController;
  late final bool _ownsUiScaleController;

  bool _isProcessingTurn = false;

  @override
  void initState() {
    super.initState();

    if (widget.uiScaleController != null) {
      _uiScaleController = widget.uiScaleController!;
      _ownsUiScaleController = false;
    } else {
      _uiScaleController = ValueNotifier<double>(1.0);
      _ownsUiScaleController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsUiScaleController) {
      _uiScaleController.dispose();
    }

    super.dispose();
  }

  Future<void> _ageUp() async {
    if (_isProcessingTurn) {
      return;
    }

    setState(() {
      _isProcessingTurn = true;
    });

    final result = engine.ageUp();

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() {
        _isProcessingTurn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result is Failure ? result.message : 'Simulation failed.',
          ),
        ),
      );

      return;
    }

    setState(() {});

    final saveResult = await engine.save();

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessingTurn = false;
    });

    if (!saveResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Year advanced, but autosave failed.',
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (_isProcessingTurn) {
      return;
    }

    final result = await engine.save();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess ? 'Game saved.' : 'Save failed.',
        ),
      ),
    );
  }

  Future<void> _load() async {
    if (_isProcessingTurn) {
      return;
    }

    final result = await engine.load();

    if (!mounted) {
      return;
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess ? 'Game loaded.' : 'Load failed.',
        ),
      ),
    );
  }

  void _openCharacterProfile() {
    if (_isProcessingTurn) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CharacterProfileScreen(
          character: engine.state.player,
          currentYear: engine.state.clock.currentYear,
          uiScaleController: _uiScaleController,
        ),
      ),
    );
  }

  void _openSettings() {
    if (_isProcessingTurn) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          uiScaleController: _uiScaleController,
        ),
      ),
    );
  }

  Future<void> _handleGameDataAction(String action) async {
    switch (action) {
      case 'save':
        await _save();
        return;

      case 'load':
        await _load();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = engine.state;
    final player = state.player;

    final age = player.ageAt(
      state.clock.currentYear,
    );

    final lifeStage = LifeStageAge.fromAge(age);

    final lifeStageLabel = _formatLifeStage(
      lifeStage,
    );

    final events = state.events.reversed.toList();

    return ValueListenableBuilder<double>(
      valueListenable: _uiScaleController,
      builder: (context, zoom, _) {
        final mediaQuery = MediaQuery.of(context);

        final scaledMediaQuery = mediaQuery.copyWith(
          textScaler: TextScaler.linear(
            zoom,
          ),
        );

        return MediaQuery(
          data: scaledMediaQuery,
          child: _buildScaffold(
            context,
            zoom,
            state,
            player,
            age,
            lifeStageLabel,
            events,
          ),
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    double zoom,
    dynamic state,
    dynamic player,
    int age,
    String lifeStageLabel,
    List<dynamic> events,
  ) {
    double s(double value) => value * zoom;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Life Simulation',
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Game Data',
            icon: Icon(
              Icons.folder_copy_outlined,
              size: s(24),
            ),
            enabled: !_isProcessingTurn,
            onSelected: _handleGameDataAction,
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'save',
                child: Row(
                  children: [
                    Icon(
                      Icons.save_outlined,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      'Save Game',
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'load',
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      'Load Game',
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: _isProcessingTurn
                ? null
                : _openSettings,
            icon: Icon(
              Icons.settings_outlined,
              size: s(24),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  s(8),
                  s(4),
                  s(8),
                  s(6),
                ),
                children: [
                  _ResponsiveCard(
                    padding: EdgeInsets.all(
                      s(8),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: const Key(
                              'character-avatar',
                            ),
                            onTap:
                                _openCharacterProfile,
                            borderRadius:
                                BorderRadius.circular(
                              s(40),
                            ),
                            child: CircleAvatar(
                              radius: s(27),
                              child: Icon(
                                player.gender ==
                                        Gender.male
                                    ? Icons.person
                                    : Icons.person_outline,
                                size: s(29),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: s(8),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name,
                                style:
                                    Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: s(1),
                              ),
                              Wrap(
                                spacing: s(8),
                                runSpacing: s(2),
                                children: [
                                  Text(
                                    'Age $age',
                                    style:
                                        Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                  ),
                                  Text(
                                    'Year '
                                    '${state.clock.currentYear}',
                                    style:
                                        Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                  ),
                                  Text(
                                    lifeStageLabel,
                                    style:
                                        Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: s(6),
                        ),
                        Flexible(
                          child: Text(
                            player.money.toString(),
                            textAlign:
                                TextAlign.end,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: s(4),
                  ),
                  _ResponsiveCard(
                    padding: EdgeInsets.fromLTRB(
                      s(8),
                      s(6),
                      s(8),
                      s(7),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Core Stats',
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                        ),
                        SizedBox(
                          height: s(5),
                        ),
                        LayoutBuilder(
                          builder:
                              (context, constraints) {
                            return GridView.extent(
                              maxCrossAxisExtent: s(120),
                              crossAxisSpacing: s(4),
                              mainAxisSpacing: s(4),
                              childAspectRatio: 2.45,
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              children: [
                                _StatCard(
                                  key: const Key(
                                    'core-stat-health',
                                  ),
                                  label: 'Health',
                                  value:
                                      player.stats.health,
                                  icon:
                                      Icons.favorite,
                                  zoom: zoom,
                                ),
                                _StatCard(
                                  key: const Key(
                                    'core-stat-intelligence',
                                  ),
                                  label:
                                      'Intelligence',
                                  value: player
                                      .stats
                                      .intelligence,
                                  icon:
                                      Icons.psychology,
                                  zoom: zoom,
                                ),
                                _StatCard(
                                  key: const Key(
                                    'core-stat-fitness',
                                  ),
                                  label: 'Fitness',
                                  value:
                                      player.stats.fitness,
                                  icon: Icons
                                      .fitness_center,
                                  zoom: zoom,
                                ),
                                _StatCard(
                                  key: const Key(
                                    'core-stat-happiness',
                                  ),
                                  label:
                                      'Happiness',
                                  value: player
                                      .stats
                                      .happiness,
                                  icon: Icons
                                      .sentiment_satisfied,
                                  zoom: zoom,
                                ),
                                _StatCard(
                                  key: const Key(
                                    'core-stat-willpower',
                                  ),
                                  label:
                                      'Willpower',
                                  value: player
                                      .stats
                                      .willpower,
                                  icon: Icons
                                      .shield_outlined,
                                  zoom: zoom,
                                ),
                                _StatCard(
                                  key: const Key(
                                    'core-stat-charisma',
                                  ),
                                  label:
                                      'Charisma',
                                  value: player
                                      .stats
                                      .charisma,
                                  icon: Icons.groups,
                                  zoom: zoom,
                                ),
                                _StatCard(
                                  key: const Key(
                                    'core-stat-creativity',
                                  ),
                                  label:
                                      'Creativity',
                                  value: player
                                      .stats
                                      .creativity,
                                  icon: Icons.palette,
                                  zoom: zoom,
                                ),
                                _StatCard(
                                  key: const Key(
                                    'core-stat-luck',
                                  ),
                                  label: 'Luck',
                                  value:
                                      player.stats.luck,
                                  icon:
                                      Icons.auto_awesome,
                                  zoom: zoom,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: s(4),
                  ),
                  _ResponsiveCard(
                    padding: EdgeInsets.fromLTRB(
                      s(8),
                      s(6),
                      s(8),
                      s(6),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Life Events',
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                        ),
                        SizedBox(
                          height: s(5),
                        ),
                        SizedBox(
                          height: s(300),
                          child: events.isEmpty
                              ? Center(
                                  child: Text(
                                    'No events yet.',
                                    textAlign:
                                        TextAlign.center,
                                  ),
                                )
                              : ListView.separated(
                                  padding:
                                      EdgeInsets.zero,
                                  itemCount:
                                      events.length,
                                  separatorBuilder:
                                      (_, __) =>
                                          SizedBox(
                                    height: s(7),
                                  ),
                                  itemBuilder:
                                      (
                                    context,
                                    index,
                                  ) {
                                    final event =
                                        events[index];

                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.only(
                                            top: s(5),
                                          ),
                                          child: Icon(
                                            Icons.circle,
                                            size: s(6),
                                            color: Theme
                                                    .of(
                                              context,
                                            )
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        SizedBox(
                                          width: s(7),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                event.title,
                                                style: Theme
                                                        .of(
                                                  context,
                                                )
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight
                                                              .w600,
                                                    ),
                                              ),
                                              SizedBox(
                                                height:
                                                    s(1),
                                              ),
                                              Text(
                                                '${event.year} — '
                                                '${event.description}',
                                                style: Theme
                                                        .of(
                                                  context,
                                                )
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                s(8),
                s(5),
                s(8),
                s(5),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: s(44),
                child: FilledButton.icon(
                  onPressed: _isProcessingTurn
                      ? null
                      : _ageUp,
                  icon: _isProcessingTurn
                      ? SizedBox(
                          width: s(17),
                          height: s(17),
                          child:
                              const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.arrow_forward,
                          size: s(18),
                        ),
                  label: Text(
                    _isProcessingTurn
                        ? 'SAVING...'
                        : 'AGE UP',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLifeStage(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'Infant';
      case LifeStage.toddler:
        return 'Toddler';
      case LifeStage.child:
        return 'Child';
      case LifeStage.teen:
        return 'Teen';
      case LifeStage.youngAdult:
        return 'Young Adult';
      case LifeStage.adult:
        return 'Adult';
      case LifeStage.senior:
        return 'Senior';
    }
  }
}

class _ResponsiveCard extends StatelessWidget {
  const _ResponsiveCard({
    required this.padding,
    required this.child,
  });

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.zoom,
    super.key,
  });

  final String label;
  final int value;
  final IconData icon;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final progress = (value / 100)
        .clamp(0.0, 1.0)
        .toDouble();

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: s(42),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: s(5),
        vertical: s(4),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          s(7),
        ),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: s(11),
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
                SizedBox(
                  width: s(2),
                ),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    textAlign:
                        TextAlign.center,
                    style:
                        Theme.of(context)
                            .textTheme
                            .labelSmall,
                  ),
                ),
                SizedBox(
                  width: s(2),
                ),
                Text(
                  '$value',
                  maxLines: 1,
                  style:
                      Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(
                            fontWeight:
                                FontWeight.w700,
                          ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: s(3),
          ),
          LinearProgressIndicator(
            value: progress,
            minHeight: s(3),
            borderRadius:
                BorderRadius.circular(
              s(4),
            ),
          ),
        ],
      ),
    );
  }
}
