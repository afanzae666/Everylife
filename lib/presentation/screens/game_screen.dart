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

  final ValueNotifier<double>?
      uiScaleController;

  @override
  State<GameScreen> createState() =>
      _GameScreenState();
}

class _GameScreenState
    extends State<GameScreen> {
  SimulationEngine get engine =>
      widget.engine;

  late final ValueNotifier<double>
      _uiScaleController;

  late final bool _ownsUiScaleController;

  bool _isProcessingTurn = false;

  @override
  void initState() {
    super.initState();

    if (widget.uiScaleController !=
        null) {
      _uiScaleController =
          widget.uiScaleController!;
      _ownsUiScaleController = false;
    } else {
      _uiScaleController =
          ValueNotifier<double>(1.0);
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            result is Failure
                ? result.message
                : 'Simulation failed.',
          ),
        ),
      );

      return;
    }

    setState(() {});

    final saveResult =
        await engine.save();

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessingTurn = false;
    });

    if (!saveResult.isSuccess) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
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

    final result =
        await engine.save();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Game saved.'
              : 'Save failed.',
        ),
      ),
    );
  }

  Future<void> _load() async {
    if (_isProcessingTurn) {
      return;
    }

    final result =
        await engine.load();

    if (!mounted) {
      return;
    }

    setState(() {});

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Game loaded.'
              : 'Load failed.',
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
        builder: (_) =>
            CharacterProfileScreen(
          character:
              engine.state.player,
          currentYear:
              engine.state.clock.currentYear,
          uiScaleController:
              _uiScaleController,
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
        builder: (_) =>
            SettingsScreen(
          uiScaleController:
              _uiScaleController,
        ),
      ),
    );
  }

  Future<void> _handleGameDataAction(
    String action,
  ) async {
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
  Widget build(
    BuildContext context,
  ) {
    final state = engine.state;
    final player = state.player;

    final age = player.ageAt(
      state.clock.currentYear,
    );

    final lifeStage =
        LifeStageAge.fromAge(age);

    final lifeStageLabel =
        _formatLifeStage(lifeStage);

    final events =
        state.events.reversed.toList();

    return ValueListenableBuilder<double>(
      valueListenable:
          _uiScaleController,
      builder:
          (context, zoom, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Life Simulation',
            ),
            actions: [
              PopupMenuButton<String>(
                tooltip: 'Game Data',
                icon: const Icon(
                  Icons
                      .folder_copy_outlined,
                ),
                enabled:
                    !_isProcessingTurn,
                onSelected:
                    _handleGameDataAction,
                itemBuilder:
                    (context) => [
                  const PopupMenuItem<
                      String>(
                    value: 'save',
                    child: Row(
                      children: [
                        Icon(
                          Icons.save_outlined,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Save Game',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<
                      String>(
                    value: 'load',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .folder_open_outlined,
                        ),
                        SizedBox(width: 12),
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
                onPressed:
                    _isProcessingTurn
                        ? null
                        : _openSettings,
                icon: const Icon(
                  Icons
                      .settings_outlined,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ClipRect(
                    child: Transform.scale(
                      scale: zoom,
                      alignment:
                          Alignment.topCenter,
                      child: ListView(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          8,
                          4,
                          8,
                          6,
                        ),
                        children: [
                          Card(
                            margin:
                                EdgeInsets.zero,
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .all(8),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .center,
                                children: [
                                  Material(
                                    color: Colors
                                        .transparent,
                                    child:
                                        InkWell(
                                      key:
                                          const Key(
                                        'character-avatar',
                                      ),
                                      onTap:
                                          _openCharacterProfile,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        40,
                                      ),
                                      child:
                                          CircleAvatar(
                                        radius: 27,
                                        child:
                                            Icon(
                                          player.gender ==
                                                  Gender
                                                      .male
                                              ? Icons
                                                  .person
                                              : Icons
                                                  .person_outline,
                                          size: 29,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          player
                                              .name,
                                          style: Theme
                                                  .of(
                                            context,
                                          )
                                              .textTheme
                                              .titleMedium,
                                          maxLines:
                                              1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                        ),
                                        const SizedBox(
                                          height: 1,
                                        ),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing:
                                              0,
                                          children: [
                                            Text(
                                              'Age $age',
                                              style: Theme
                                                      .of(
                                                context,
                                              )
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            Text(
                                              'Year '
                                              '${state.clock.currentYear}',
                                              style: Theme
                                                      .of(
                                                context,
                                              )
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            Text(
                                              lifeStageLabel,
                                              style: Theme
                                                      .of(
                                                context,
                                              )
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    player.money
                                        .toString(),
                                    style: Theme.of(
                                      context,
                                    )
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Card(
                            margin:
                                EdgeInsets.zero,
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                8,
                                6,
                                8,
                                7,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'Core Stats',
                                    style: Theme
                                            .of(
                                      context,
                                    )
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  GridView.count(
                                    crossAxisCount:
                                        4,
                                    crossAxisSpacing:
                                        4,
                                    mainAxisSpacing:
                                        4,
                                    mainAxisExtent:
                                        47,
                                    shrinkWrap:
                                        true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      _StatCard(
                                        key:
                                            const Key(
                                          'core-stat-health',
                                        ),
                                        label:
                                            'Health',
                                        value:
                                            player
                                                .stats
                                                .health,
                                        icon: Icons
                                            .favorite,
                                      ),
                                      _StatCard(
                                        key:
                                            const Key(
                                          'core-stat-intelligence',
                                        ),
                                        label:
                                            'Intelligence',
                                        value:
                                            player
                                                .stats
                                                .intelligence,
                                        icon: Icons
                                            .psychology,
                                      ),
                                      _StatCard(
                                        key:
                                            const Key(
                                          'core-stat-fitness',
                                        ),
                                        label:
                                            'Fitness',
                                        value:
                                            player
                                                .stats
                                                .fitness,
                                        icon: Icons
                                            .fitness_center,
                                      ),
                                      _StatCard(
                                        key:
                                            const Key(
                                          'core-stat-happiness',
                                        ),
                                        label:
                                            'Happiness',
                                        value:
                                            player
                                                .stats
                                                .happiness,
                                        icon: Icons
                                            .sentiment_satisfied,
                                      ),
                                      _StatCard(
                                        key:
                                            const Key(
                                          'core-stat-willpower',
                                        ),
                                        label:
                                            'Willpower',
                                        value:
                                            player
                                                .stats
                                                .willpower,
                                        icon: Icons
                                            .shield_outlined,
                                      ),
                                      _StatCard(
                                        key:
                                            const Key(
                                          'core-stat-charisma',
                                        ),
                                        label:
                                            'Charisma',
                                        value:
                                            player
                                                .stats
                                                .charisma,
                                        icon: Icons
                                            .groups,
                                      ),
                                      _StatCard(
                                        key:
                                            const Key(
                                          'core-stat-creativity',
                                        ),
                                        label:
                                            'Creativity',
                                        value:
                                            player
                                                .stats
                                                .creativity,
                                        icon: Icons
                                            .palette,
                                      ),
                                      _StatCard(
                                        key:
                                            const Key(
                                          'core-stat-luck',
                                        ),
                                        label:
                                            'Luck',
                                        value:
                                            player
                                                .stats
                                                .luck,
                                        icon: Icons
                                            .auto_awesome,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Card(
                            margin:
                                EdgeInsets.zero,
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                8,
                                6,
                                8,
                                6,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'Life Events',
                                    style: Theme
                                            .of(
                                      context,
                                    )
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    height: 300,
                                    child: events
                                            .isEmpty
                                        ? const Center(
                                            child:
                                                Text(
                                              'No events yet.',
                                            ),
                                          )
                                        : ListView
                                            .separated(
                                            padding:
                                                EdgeInsets
                                                    .zero,
                                            itemCount:
                                                events
                                                    .length,
                                            separatorBuilder:
                                                (
                                              _,
                                              __,
                                            ) =>
                                                    const SizedBox(
                                              height:
                                                  7,
                                            ),
                                            itemBuilder:
                                                (
                                              context,
                                              index,
                                            ) {
                                              final event =
                                                  events[
                                                      index];

                                              return Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top:
                                                          5,
                                                    ),
                                                    child:
                                                        Icon(
                                                      Icons
                                                          .circle,
                                                      size:
                                                          6,
                                                      color:
                                                          Theme.of(
                                                        context,
                                                      )
                                                              .colorScheme
                                                              .primary,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width:
                                                        7,
                                                  ),
                                                  Expanded(
                                                    child:
                                                        Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          event
                                                              .title,
                                                          style:
                                                              Theme.of(
                                                            context,
                                                          )
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight.w600,
                                                                  ),
                                                        ),
                                                        const SizedBox(
                                                          height:
                                                              1,
                                                        ),
                                                        Text(
                                                          '${event.year} — '
                                                          '${event.description}',
                                                          style:
                                                              Theme.of(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.fromLTRB(
                    8,
                    5,
                    8,
                    5,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor,
                    border:
                        Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width:
                        double.infinity,
                    height: 44,
                    child:
                        FilledButton.icon(
                      onPressed:
                          _isProcessingTurn
                              ? null
                              : _ageUp,
                      icon:
                          _isProcessingTurn
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .arrow_forward,
                                  size: 18,
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
      },
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

class _StatCard
    extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(
    BuildContext context,
  ) {
    final progress =
        (value / 100)
            .clamp(0.0, 1.0)
            .toDouble();

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(7),
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
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 11,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
              const SizedBox(
                width: 2,
              ),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  textAlign:
                      TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Text(
                '$value',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall!
                    .copyWith(
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 3,
          ),
          LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            borderRadius:
                BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
