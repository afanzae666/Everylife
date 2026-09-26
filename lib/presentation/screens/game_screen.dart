import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/result/result.dart';
import '../../domain/character/gender.dart';
import '../../domain/character/life_stage.dart';
import '../../simulation/engine/simulation_engine.dart';
import 'character_profile_screen.dart';
import 'settings_screen.dart';

Future<void> _defaultUiScaleChanged(double value) async {}

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.engine,
    this.onUiScaleChanged = _defaultUiScaleChanged,
    this.uiScaleController,
    super.key,
  });

  final SimulationEngine engine;
  final Future<void> Function(double value) onUiScaleChanged;
  final ValueNotifier<double>? uiScaleController;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  SimulationEngine get engine => widget.engine;

  late final ValueNotifier<double> _uiScaleController;
  late final bool _ownsUiScaleController;

  bool _isProcessingTurn = false;
  final ScrollController _lifeEventsScrollController =
      ScrollController();
  
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

    _lifeEventsScrollController.dispose();

    super.dispose();
  }
  
  void _scrollLifeEventsToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_lifeEventsScrollController.hasClients) {
        return;
      }

      final maxScrollExtent =
          _lifeEventsScrollController.position.maxScrollExtent;

      if (maxScrollExtent <= 0) {
        return;
      }

      _lifeEventsScrollController.animateTo(
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
            result is Failure
                ? result.message
                : 'Simulation failed.',
          ),
        ),
      );

      return;
    }

    setState(() {});

_scrollLifeEventsToBottom();

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

_scrollLifeEventsToBottom();

ScaffoldMessenger.of(context).showSnackBar(
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
          onUiScaleChanged: widget.onUiScaleChanged,
        ),
      ),
    );
  }

  void _showNavigationNotice(String destination) {
    if (_isProcessingTurn) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$destination is ready for its feature screen.',
          ),
          duration: const Duration(
            milliseconds: 1200,
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

    // Events are already stored chronologically.
    // WorldState.addEvent() appends new events to the end,
    // so do not reverse this list.
    final events = state.events;

    return ValueListenableBuilder<double>(
      valueListenable: _uiScaleController,
      builder: (context, zoom, _) {
        final mediaQuery = MediaQuery.of(context);

        final scaledMediaQuery = mediaQuery.copyWith(
          textScaler: TextScaler.linear(zoom),
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
                      onTap: _openCharacterProfile,
                      borderRadius:
                          BorderRadius.circular(
                        s(40),
                      ),
                      child: CircleAvatar(
                        radius: s(27),
                        child: Icon(
                          player.gender == Gender.male
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
                        Wrap(
                          spacing: s(8),
                          runSpacing: 0,
                          children: [
                            Text(
                              'Age $age',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                            Text(
                              'Year '
                              '${state.clock.currentYear}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                            Text(
                              lifeStageLabel,
                              style: Theme.of(context)
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
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: Theme.of(context)
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
                            value: player
                                .stats
                                .health,
                            icon:
                                Icons.favorite,
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
                            value: player
                                .stats
                                .fitness,
                            icon: Icons
                                .fitness_center,
                            zoom: zoom,
                          );

                        case 3:
                          return _StatCard(
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
                          );

                        case 4:
                          return _StatCard(
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
                          );

                        case 5:
                          return _StatCard(
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
                          );

                        case 6:
                          return _StatCard(
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
                          );

                        case 7:
                          return _StatCard(
                            key: const Key(
                              'core-stat-luck',
                            ),
                            label: 'Luck',
                            value: player
                                .stats
                                .luck,
                            icon: Icons
                                .auto_awesome,
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
            ),

            SizedBox(
              height: s(4),
            ),

            Expanded(
              child: _ResponsiveCard(
                padding: EdgeInsets.fromLTRB(
                  s(8),
                  s(6),
                  s(8),
                  s(6),
                ),
                child: events.isEmpty
                    ? Center(
                        child: Text(
                          'No events yet.',
                          textAlign:
                              TextAlign.center,
                        ),
                      )
                : ListView.separated(
    controller: _lifeEventsScrollController,
    padding: EdgeInsets.zero,
    itemCount:
        events.length,
                        separatorBuilder:
                            (
                          _,
                          __,
                        ) =>
                                SizedBox(
                          height: s(7),
                        ),
                        itemBuilder: (
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
                                  color: Theme.of(
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
            ),

            SizedBox(
              height: s(4),
            ),

            _BottomNavigation(
              zoom: zoom,
              isProcessing:
                  _isProcessingTurn,
              onCareerTap: () {
                _showNavigationNotice(
                  'Career',
                );
              },
              onAssetsTap: () {
                _showNavigationNotice(
                  'Assets',
                );
              },
              onAgeUpTap: _ageUp,
              onLifeTap: () {
                _showNavigationNotice(
                  'Life',
                );
              },
              onMoreTap: () {
                _showNavigationNotice(
                  'More',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  int _getStatColumnCount(
    double availableWidth,
    double zoom,
  ) {
    if (zoom <= 1.15) {
      return 4;
    }

    if (zoom <= 1.55) {
      return availableWidth >= 320 ? 3 : 2;
    }

    return availableWidth >= 320 ? 2 : 1;
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

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.zoom,
    required this.isProcessing,
    required this.onCareerTap,
    required this.onAssetsTap,
    required this.onAgeUpTap,
    required this.onLifeTap,
    required this.onMoreTap,
  });

  final double zoom;
  final bool isProcessing;
  final VoidCallback onCareerTap;
  final VoidCallback onAssetsTap;
  final VoidCallback onAgeUpTap;
  final VoidCallback onLifeTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final textStyle = Theme.of(context)
        .textTheme
        .labelSmall!
        .copyWith(
          fontWeight: FontWeight.w600,
        );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        s(4),
        s(4),
        s(4),
        s(4),
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
        height: s(60),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            _BottomNavigationItem(
              key: const Key(
                'bottom-nav-career',
              ),
              label: 'Career',
              assetPath:
                  'assets/icons/career.svg',
              iconSize: s(25),
              textStyle: textStyle,
              onTap: onCareerTap,
            ),
            _BottomNavigationItem(
              key: const Key(
                'bottom-nav-assets',
              ),
              label: 'Assets',
              assetPath:
                  'assets/icons/assets.svg',
              iconSize: s(25),
              textStyle: textStyle,
              onTap: onAssetsTap,
            ),
            _AgeUpNavigationItem(
              key: const Key(
                'bottom-nav-age-up',
              ),
              zoom: zoom,
              isProcessing:
                  isProcessing,
              onTap: onAgeUpTap,
              textStyle: textStyle,
            ),
            _BottomNavigationItem(
              key: const Key(
                'bottom-nav-life',
              ),
              label: 'Life',
              assetPath:
                  'assets/icons/life.svg',
              iconSize: s(25),
              textStyle: textStyle,
              onTap: onLifeTap,
            ),
            _BottomNavigationItem(
              key: const Key(
                'bottom-nav-more',
              ),
              label: 'More',
              assetPath:
                  'assets/icons/more.svg',
              iconSize: s(25),
              textStyle: textStyle,
              onTap: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavigationItem
    extends StatelessWidget {
  const _BottomNavigationItem({
    required this.label,
    required this.assetPath,
    required this.iconSize,
    required this.textStyle,
    required this.onTap,
    super.key,
  });

  final String label;
  final String assetPath;
  final double iconSize;
  final TextStyle textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(10),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: SvgPicture.asset(
                  assetPath,
                  semanticsLabel: label,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height:
                    1 * (iconSize / 25),
              ),
              Text(
                label,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgeUpNavigationItem
    extends StatelessWidget {
  const _AgeUpNavigationItem({
    required this.zoom,
    required this.isProcessing,
    required this.onTap,
    required this.textStyle,
    super.key,
  });

  final double zoom;
  final bool isProcessing;
  final VoidCallback onTap;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final colorScheme =
        Theme.of(context).colorScheme;

    return Expanded(
      child: Semantics(
        button: true,
        label: 'Age Up',
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: -s(17),
              child: SizedBox(
                width: s(72),
                height: s(72),
                child: FilledButton(
                  onPressed:
                      isProcessing
                          ? null
                          : onTap,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape:
                        const CircleBorder(),
                    backgroundColor:
                        colorScheme.surface,
                    foregroundColor:
                        colorScheme.primary,
                    disabledBackgroundColor:
                        colorScheme.surface,
                    disabledForegroundColor:
                        colorScheme
                            .onSurfaceVariant,
                    side: BorderSide(
                      color:
                          colorScheme.primary,
                      width: s(1.5),
                    ),
                    elevation: 5,
                    shadowColor:
                        Colors.black54,
                  ),
                  child: isProcessing
                      ? SizedBox(
                          width: s(28),
                          height: s(28),
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                s(2.2),
                            color:
                                colorScheme
                                    .primary,
                          ),
                        )
                      : ClipOval(
                          child: SizedBox(
                            width: s(58),
                            height: s(58),
                            child:
                                Transform.scale(
                              scale: 1.55,
                              child:
                                  Image.asset(
                                'assets/icons/age_up.png',
                                width: s(58),
                                height: s(58),
                                fit: BoxFit
                                    .contain,
                                color:
                                    colorScheme
                                        .primary,
                                colorBlendMode:
                                    BlendMode
                                        .srcIn,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveCard
    extends StatelessWidget {
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

class _StatCard
    extends StatelessWidget {
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

    final progress = (value / 100)
        .clamp(0.0, 1.0)
        .toDouble();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: s(4),
        vertical: s(2),
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(
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
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: s(11),
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
              SizedBox(
                width: s(3),
              ),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  softWrap: true,
                  textAlign:
                      TextAlign.start,
                  overflow:
                      TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall,
                ),
              ),
              SizedBox(
                width: s(3),
              ),
              Text(
                '$value',
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall!
                    .copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
              ),
            ],
          ),
          SizedBox(
            height: s(1),
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
