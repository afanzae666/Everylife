import 'package:flutter/material.dart';

import '../../domain/character/gender.dart';
import '../../domain/character/life_stage.dart';
import '../../simulation/engine/simulation_engine.dart';
import 'character_profile_screen.dart';
import 'save_load_screen.dart';
import 'settings_screen.dart';
import 'assets_screen.dart';
import 'career_screen.dart';
import 'life_screen.dart';
import 'more_screen.dart';

Future<void> _defaultUiScaleChanged(
  double value,
) async {}

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.engine,
    this.onUiScaleChanged =
        _defaultUiScaleChanged,
    this.uiScaleController,
    super.key,
  });

  final SimulationEngine engine;
  final Future<void> Function(double value)
      onUiScaleChanged;
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

  late final bool
      _ownsUiScaleController;

  late final ValueNotifier<bool>
      _autoSaveController;

  bool _isProcessingTurn = false;

  int _selectedNavigationIndex = 0;

  final ScrollController
      _lifeEventsScrollController =
      ScrollController();

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

    _autoSaveController =
        ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    if (_ownsUiScaleController) {
      _uiScaleController.dispose();
    }

    _autoSaveController.dispose();

    _lifeEventsScrollController
        .dispose();

    super.dispose();
  }

  void _scrollLifeEventsToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted ||
          !_lifeEventsScrollController
              .hasClients) {
        return;
      }

      final maxScrollExtent =
          _lifeEventsScrollController
              .position
              .maxScrollExtent;

      if (maxScrollExtent <= 0) {
        return;
      }

      _lifeEventsScrollController
          .animateTo(
        maxScrollExtent,
        duration: const Duration(
          milliseconds: 350,
        ),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _ageUp() async {
    if (_isProcessingTurn) {
      return;
    }

    setState(() {
      _isProcessingTurn = true;
    });

    final result =
        engine.ageUp();

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() {
        _isProcessingTurn = false;
      });

      return;
    }

    setState(() {});

    _scrollLifeEventsToBottom();

    if (_autoSaveController.value) {
      await engine.save();

      if (!mounted) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessingTurn = false;
    });
  }

  Future<void> _openSaveManager() async {
    if (_isProcessingTurn) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SaveLoadScreen(
          zoom:
              _uiScaleController.value,
          autoSaveController:
              _autoSaveController,
          onRead:
              engine.readSaveSlot,
          onSave:
              engine.saveToSlot,
          onLoad:
              engine.loadFromSlot,
          onDelete:
              engine.deleteSave,
          onGameStateChanged: () {
            if (mounted) {
              setState(() {});
              _scrollLifeEventsToBottom();
            }
          },
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
          currentYear: engine
              .state
              .clock
              .currentYear,
          uiScaleController:
              _uiScaleController,
          onViewAssets:
              _openAssetsFromProfile,
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
          uiScaleController:
              _uiScaleController,
          onUiScaleChanged:
              widget.onUiScaleChanged,
        ),
      ),
    );
  }

  void _openAssetsTab() {
    if (_isProcessingTurn) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssetsScreen(
          player: engine.state.player,
          zoom: _uiScaleController.value,
        ),
      ),
    );
  }

  void _openAssetsFromProfile() {
    if (_isProcessingTurn) {
      return;
    }

    Navigator.of(context).pop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isProcessingTurn) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AssetsScreen(
            player: engine.state.player,
            zoom: _uiScaleController.value,
          ),
        ),
      );
    });
  }

  void _openCareerPage() {
    if (_isProcessingTurn) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CareerScreen(
          zoom: _uiScaleController.value,
        ),
      ),
    );
  }

  void _openLifePage() {
    if (_isProcessingTurn) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LifeScreen(
          zoom: _uiScaleController.value,
        ),
      ),
    );
  }

  void _openMorePage() {
    if (_isProcessingTurn) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MoreScreen(
          zoom: _uiScaleController.value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = engine.state;
    final player = state.player;

    final age = player.ageAt(
      state.clock.currentYear,
    );

    final lifeStage =
        LifeStageAge.fromAge(age);

    final lifeStageLabel =
        _formatLifeStage(
      lifeStage,
    );

    final events = state.events;

    return ValueListenableBuilder<double>(
      valueListenable:
          _uiScaleController,
      builder: (
        context,
        zoom,
        _,
      ) {
        final mediaQuery =
            MediaQuery.of(context);

        final scaledMediaQuery =
            mediaQuery.copyWith(
          textScaler:
              TextScaler.linear(zoom),
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
    double s(double value) =>
        value * zoom;

    final showAssets =
        _selectedNavigationIndex == 1;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/everylife_logo.png',
          height: s(34),
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            tooltip: 'Save / Load',
            onPressed:
                _isProcessingTurn
                    ? null
                    : _openSaveManager,
            icon: Icon(
              Icons.folder_copy_outlined,
              size: s(24),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed:
                _isProcessingTurn
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
        child: showAssets
            ? Column(
                children: [
                  Expanded(
                    child:
                        _buildAssetsTab(
                      context,
                      zoom,
                      player,
                    ),
                  ),
                  SizedBox(
                    height: s(4),
                  ),
                  _buildBottomNavigation(
                    context,
                    zoom,
                  ),
                ],
              )
            : Column(
                children: [
                  _buildCharacterCard(
                    context,
                    zoom,
                    state,
                    player,
                    age,
                    lifeStageLabel,
                  ),
                  SizedBox(
                    height: s(4),
                  ),
                  Expanded(
                    child:
                        _buildLifeEventsCard(
                      context,
                      zoom,
                      player,
                      events,
                    ),
                  ),
                  SizedBox(
                    height: s(4),
                  ),
                  _buildCoreStatsCard(
                    context,
                    zoom,
                    player,
                  ),
                  SizedBox(
                    height: s(4),
                  ),
                  _buildBottomNavigation(
                    context,
                    zoom,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCharacterCard(
    BuildContext context,
    double zoom,
    dynamic state,
    dynamic player,
    int age,
    String lifeStageLabel,
  ) {
    double s(double value) =>
        value * zoom;

    return _ResponsiveCard(
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
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: s(1),
                ),
                Text(
                  'Age $age • '
                  '${state.clock.currentYear}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: s(1),
                ),
                Text(
                  lifeStageLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(
            width: s(6),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  player.money.toString(),
                  textAlign:
                      TextAlign.end,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),
                Text(
                  'Cash',
                  textAlign:
                      TextAlign.end,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeEventsCard(
    BuildContext context,
    double zoom,
    dynamic player,
    List<dynamic> events,
  ) {
    double s(double value) =>
        value * zoom;

    return _ResponsiveCard(
      padding: EdgeInsets.fromLTRB(
        s(8),
        s(6),
        s(8),
        s(6),
      ),
      child: events.isEmpty
          ? const Center(
              child: Text(
                'No events yet.',
                textAlign:
                    TextAlign.center,
              ),
            )
          : ListView.separated(
              controller:
                  _lifeEventsScrollController,
              padding: EdgeInsets.zero,
              itemCount: events.length,
              separatorBuilder:
                  (_, __) =>
                      SizedBox(
                height: s(7),
              ),
              itemBuilder: (
                context,
                index,
              ) {
                final event =
                    events[index];

                final eventAge =
                    event.year -
                        player.birthYear;

                return Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(
                        top: s(5),
                      ),
                      child: Icon(
                        Icons.circle,
                        size: s(6),
                        color:
                            Theme.of(
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
                            'Age $eventAge • '
                            '${event.year}',
                            style:
                                Theme.of(
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
                            height: s(1),
                          ),
                          Text(
                            event.description,
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
    );
  }

  Widget _buildCoreStatsCard(
    BuildContext context,
    double zoom,
    dynamic player,
  ) {
    double s(double value) =>
        value * zoom;

    return _ResponsiveCard(
      padding: EdgeInsets.fromLTRB(
        s(8),
        s(6),
        s(8),
        s(7),
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final crossAxisCount =
              _getStatColumnCount(
            constraints.maxWidth,
            zoom,
          );

          final spacing = s(4);

          return GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  crossAxisCount,
              crossAxisSpacing:
                  spacing,
              mainAxisSpacing:
                  spacing,
              mainAxisExtent:
                  s(50),
            ),
            itemCount: 8,
            itemBuilder: (
              context,
              index,
            ) {
              switch (index) {
                case 0:
                  return _StatCard(
                    key: const Key(
                      'core-stat-health',
                    ),
                    label: 'Health',
                    value:
                        player.stats.health,
                    icon: Icons.favorite,
                    zoom: zoom,
                  );

                case 1:
                  return _StatCard(
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
                  );

                case 2:
                  return _StatCard(
                    key: const Key(
                      'core-stat-fitness',
                    ),
                    label: 'Fitness',
                    value:
                        player.stats.fitness,
                    icon:
                        Icons.fitness_center,
                    zoom: zoom,
                  );

                case 3:
                  return _StatCard(
                    key: const Key(
                      'core-stat-happiness',
                    ),
                    label:
                        'Happiness',
                    value:
                        player.stats.happiness,
                    icon: Icons
                        .sentiment_satisfied,
                    zoom: zoom,
                  );

                case 4:
                  return _StatCard(
                    key: const Key(
                      'core-stat-willpower',
                    ),
                    label:
                        'Willpower',
                    value:
                        player.stats.willpower,
                    icon: Icons
                        .shield_outlined,
                    zoom: zoom,
                  );

                case 5:
                  return _StatCard(
                    key: const Key(
                      'core-stat-charisma',
                    ),
                    label: 'Charisma',
                    value:
                        player.stats.charisma,
                    icon: Icons.groups,
                    zoom: zoom,
                  );

                case 6:
                  return _StatCard(
                    key: const Key(
                      'core-stat-creativity',
                    ),
                    label:
                        'Creativity',
                    value:
                        player.stats.creativity,
                    icon: Icons.palette,
                    zoom: zoom,
                  );

                case 7:
                  return _StatCard(
                    key: const Key(
                      'core-stat-luck',
                    ),
                    label: 'Luck',
                    value:
                        player.stats.luck,
                    icon:
                        Icons.auto_awesome,
                    zoom: zoom,
                  );

                default:
                  return const SizedBox
                      .shrink();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildAssetsTab(
    BuildContext context,
    double zoom,
    dynamic player,
  ) {
    double s(double value) =>
        value * zoom;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        s(8),
        s(4),
        s(8),
        s(12),
      ),
      children: [
        SizedBox(
          height: s(2),
        ),
        Text(
          'Assets',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
        ),
        SizedBox(
          height: s(2),
        ),
        Text(
          'Everything your character owns.',
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
        SizedBox(
          height: s(6),
        ),
        _ResponsiveCard(
          padding: EdgeInsets.fromLTRB(
            s(8),
            s(7),
            s(8),
            s(7),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Current Assets',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
              ),
              SizedBox(
                height: s(4),
              ),
              _AssetSummaryRow(
                label: 'Cash',
                value:
                    player.money.toString(),
                zoom: zoom,
              ),
              _AssetSummaryRow(
                label: 'Property',
                value: 'None',
                zoom: zoom,
              ),
              _AssetSummaryRow(
                label: 'Businesses',
                value: 'None',
                zoom: zoom,
              ),
              _AssetSummaryRow(
                label: 'Investments',
                value: 'None',
                zoom: zoom,
              ),
              _AssetSummaryRow(
                label: 'Vehicles',
                value: 'None',
                zoom: zoom,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    double zoom,
  ) {
    return _BottomNavigation(
      zoom: zoom,
      isProcessing: _isProcessingTurn,
      selectedIndex:
          _selectedNavigationIndex,
      onCareerTap: _openCareerPage,
      onAssetsTap: _openAssetsTab,
      onAgeUpTap: _ageUp,
      onLifeTap: _openLifePage,
      onMoreTap: _openMorePage,
    );
  }

  int _getStatColumnCount(
    double availableWidth,
    double zoom,
  ) {
    if (zoom <= 1.15) {
      return 4;
    }

    if (zoom <= 1.3) {
      return 3;
    }

    return 2;
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
    required this.child,
    required this.padding,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: padding,
        child: child,
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
    double s(double value) =>
        value * zoom;

    return _ResponsiveCard(
      padding: EdgeInsets.symmetric(
        horizontal: s(4),
        vertical: s(4),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: s(18),
          ),
          SizedBox(
            height: s(4),
          ),
          Text(
            value.toString(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(
            height: s(2),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AssetSummaryRow extends StatelessWidget {
  const _AssetSummaryRow({
    required this.label,
    required this.value,
    required this.zoom,
  });

  final String label;
  final String value;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) =>
        value * zoom;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: s(3),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.zoom,
    required this.isProcessing,
    required this.selectedIndex,
    required this.onCareerTap,
    required this.onAssetsTap,
    required this.onAgeUpTap,
    required this.onLifeTap,
    required this.onMoreTap,
  });

  final double zoom;
  final bool isProcessing;
  final int selectedIndex;
  final VoidCallback onCareerTap;
  final VoidCallback onAssetsTap;
  final Future<void> Function() onAgeUpTap;
  final VoidCallback onLifeTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    double s(double value) =>
        value * zoom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: s(4),
          vertical: s(4),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.work_outline,
                size: s(24),
              ),
              onPressed: isProcessing
                  ? null
                  : onCareerTap,
              tooltip: 'Career',
            ),
            IconButton(
              icon: Icon(
                Icons.home_outlined,
                size: s(24),
              ),
              onPressed: isProcessing
                  ? null
                  : onAssetsTap,
              tooltip: 'Assets',
            ),
            ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () async {
                      await onAgeUpTap();
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: s(16),
                  vertical: s(8),
                ),
              ),
              child: Text(
                'Age Up',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.favorite_outline,
                size: s(24),
              ),
              onPressed: isProcessing
                  ? null
                  : onLifeTap,
              tooltip: 'Life',
            ),
            IconButton(
              icon: Icon(
                Icons.more_horiz_outlined,
                size: s(24),
              ),
              onPressed: isProcessing
                  ? null
                  : onMoreTap,
              tooltip: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
