import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/money/money.dart';
import '../../data/settings/auto_save_settings.dart';
import '../../domain/character/gender.dart';
import '../../domain/character/life_stage.dart';
import '../../simulation/engine/simulation_engine.dart';
import 'assets_screen.dart';
import 'career_screen.dart';
import 'character_profile_screen.dart';
import 'life_screen.dart';
import 'more_screen.dart';
import 'save_load_screen.dart';
import 'settings_screen.dart';

Future<void> _defaultUiScaleChanged(double value) async {}

const Color _everyLifeCardColor = Color(0xFFF5F2F9);
const Color _everyLifeSurfaceColor = Color(0xFFFBF8FF);
const Color _everyLifeAgeUpBorder = Color(0xFF5B5E86);

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
  late final ValueNotifier<bool> _autoSaveController;
  late final AutoSaveSettings _autoSaveSettings;

  bool _autoSaveSettingReady = false;
  bool _isProcessingTurn = false;
  bool _isExitDialogShowing = false;

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

    _autoSaveController = ValueNotifier<bool>(true);

    _autoSaveSettings = AutoSaveSettings();

    _autoSaveController.addListener(
      _handleAutoSaveSettingChanged,
    );

    _loadAutoSaveSetting();

    _scrollLifeEventsToBottom(jump: true);
  }

  @override
  void dispose() {
    if (_ownsUiScaleController) {
      _uiScaleController.dispose();
    }

    _autoSaveController.removeListener(
      _handleAutoSaveSettingChanged,
    );

    _autoSaveController.dispose();
    _lifeEventsScrollController.dispose();

    super.dispose();
  }

  Future<void> _loadAutoSaveSetting() async {
    final enabled = await _autoSaveSettings.load();

    if (!mounted) {
      return;
    }

    _autoSaveSettingReady = true;

    _autoSaveController.value = enabled;
  }

  void _handleAutoSaveSettingChanged() {
    if (!_autoSaveSettingReady) {
      return;
    }

    _autoSaveSettings.save(
      _autoSaveController.value,
    );
  }

  Future<void> _confirmExitGame() async {
    if (!mounted || _isExitDialogShowing) {
      return;
    }

    _isExitDialogShowing = true;

    try {
      final shouldExit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Do you want to leave this world?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('STAY'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('EXIT'),
              ),
            ],
          );
        },
      );

      if (shouldExit == true && mounted) {
        await SystemNavigator.pop();
      }
    } finally {
      _isExitDialogShowing = false;
    }
  }

  void _scrollLifeEventsToBottom({
    bool jump = false,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_lifeEventsScrollController.hasClients) {
        return;
      }

      final position = _lifeEventsScrollController.position;

      if (position.maxScrollExtent <= 0) {
        return;
      }

      if (jump) {
        _lifeEventsScrollController.jumpTo(
          position.maxScrollExtent,
        );
        return;
      }

      _lifeEventsScrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
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
        builder: (_) => SaveLoadScreen(
          zoom: _uiScaleController.value,
          autoSaveController: _autoSaveController,
          onRead: engine.readSaveSlot,
          onSave: engine.saveToSlot,
          onLoad: engine.loadFromSlot,
          onDelete: engine.deleteSave,
          onGameStateChanged: () {
            if (!mounted) {
              return;
            }

            setState(() {});
            _scrollLifeEventsToBottom();
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
        builder: (_) => CharacterProfileScreen(
          character: engine.state.player,
          currentYear: engine.state.clock.currentYear,
          uiScaleController: _uiScaleController,
          onViewAssets: _openAssetsFromProfile,
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

  String _formatMoney(Money amount) {
    final wholeUnits =
        amount.minorUnits ~/ Money.minorUnitsPerUnit;
    final absoluteUnits = wholeUnits.abs();

    if (absoluteUnits < 1000000) {
      return '\$$wholeUnits';
    }

    const units = <String>[
      'M',
      'B',
      'T',
      'Qa',
      'Qi',
      'Sx',
      'Sp',
      'Oc',
      'No',
      'Dc',
      'Ud',
      'Dd',
      'Td',
      'Qad',
      'Qid',
      'Sxd',
      'Spd',
      'Ocd',
      'Nod',
      'Vg',
    ];

    var scaled = absoluteUnits.toDouble();
    var unitIndex = -1;

    while (
      scaled >= 1000 &&
      unitIndex < units.length - 1
    ) {
      scaled /= 1000;
      unitIndex++;
    }

    final formatted = scaled >= 100
        ? scaled.toStringAsFixed(0)
        : scaled >= 10
            ? scaled.toStringAsFixed(1)
            : scaled.toStringAsFixed(2);

    final trimmed = formatted.replaceFirst(
      RegExp(r'\.?0+$'),
      '',
    );

    final sign = wholeUnits < 0 ? '-' : '';

    return '\$$sign$trimmed${units[unitIndex]}';
  }

  @override
  Widget build(BuildContext context) {
    final state = engine.state;
    final player = state.player;

    final age = player.ageAt(
      state.clock.currentYear,
    );

    final lifeStageLabel = _formatLifeStage(
      LifeStageAge.fromAge(age),
    );

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        _confirmExitGame();
      },
      child: ValueListenableBuilder<double>(
        valueListenable: _uiScaleController,
        builder: (
          context,
          zoom,
          _,
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
              state,
              player,
              age,
              lifeStageLabel,
              state.events,
            ),
          );
        },
      ),
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
      backgroundColor: _everyLifeSurfaceColor,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/everylife_logo.png',
          height: s(38),
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            tooltip: 'Save / Load',
            onPressed: _isProcessingTurn
                ? null
                : _openSaveManager,
            icon: Icon(
              Icons.folder_copy_outlined,
              size: s(24),
            ),
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
            _buildCharacterCard(
              context,
              zoom,
              state,
              player,
              age,
              lifeStageLabel,
            ),
            SizedBox(height: s(2)),
            Expanded(
              child: _buildLifeEventsCard(
                context,
                zoom,
                player,
                events,
              ),
            ),
            SizedBox(height: s(2)),
            _buildCoreStatsCard(
              context,
              zoom,
              player,
            ),
            SizedBox(height: s(6)),
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
    double s(double value) => value * zoom;

    return _ResponsiveCard(
      padding: EdgeInsets.all(s(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('character-avatar'),
              onTap: _openCharacterProfile,
              borderRadius: BorderRadius.circular(s(40)),
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
          SizedBox(width: s(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: s(1)),
                Text(
                  'Age $age • ${state.clock.currentYear}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: s(1)),
                Text(
                  lifeStageLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: s(6)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _formatMoney(player.money),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
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
    double s(double value) => value * zoom;

    final eventsByYear = <int, List<dynamic>>{};

    for (final event in events) {
      eventsByYear.putIfAbsent(
        event.year as int,
        () => [],
      ).add(event);
    }

    final groupedEvents = eventsByYear.entries.toList();

    return _ResponsiveCard(
      padding: EdgeInsets.fromLTRB(
        s(8),
        s(6),
        s(8),
        s(6),
      ),
      child: groupedEvents.isEmpty
          ? const Center(
              child: Text(
                'No events yet.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              controller: _lifeEventsScrollController,
              padding: EdgeInsets.zero,
              itemCount: groupedEvents.length,
              separatorBuilder: (_, __) => SizedBox(
                height: s(7),
              ),
              itemBuilder: (
                context,
                index,
              ) {
                final yearGroup = groupedEvents[index];
                final year = yearGroup.key;
                final yearEvents = yearGroup.value;
                final eventAge =
                    year - player.birthYear;

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: s(5),
                          ),
                          child: Icon(
                            Icons.circle,
                            size: s(6),
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                          ),
                        ),
                        SizedBox(width: s(7)),
                        Expanded(
                          child: Text(
                            'Age $eventAge • $year',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: s(2)),
                    Padding(
                      padding: EdgeInsets.only(
                        left: s(13),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          for (
                            var eventIndex = 0;
                            eventIndex <
                                yearEvents.length;
                            eventIndex++
                          ) ...[
                            if (eventIndex > 0)
                              SizedBox(height: s(2)),
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(
                                    top: s(4),
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    size: s(4),
                                    color: Theme.of(
                                      context,
                                    )
                                        .colorScheme
                                        .primary
                                        .withValues(
                                          alpha: 0.7,
                                        ),
                                  ),
                                ),
                                SizedBox(width: s(6)),
                                Expanded(
                                  child: Text(
                                    yearEvents[eventIndex]
                                        .description,
                                    style: Theme.of(
                                      context,
                                    )
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    double s(double value) => value * zoom;

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

          final spacing = s(2);

          return GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: s(50),
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
                    value: player.stats.health,
                    icon: Icons.favorite,
                    zoom: zoom,
                  );

                case 1:
                  return _StatCard(
                    key: const Key(
                      'core-stat-intelligence',
                    ),
                    label: 'Intelligence',
                    value:
                        player.stats.intelligence,
                    icon: Icons.psychology,
                    zoom: zoom,
                  );

                case 2:
                  return _StatCard(
                    key: const Key(
                      'core-stat-fitness',
                    ),
                    label: 'Fitness',
                    value: player.stats.fitness,
                    icon: Icons.fitness_center,
                    zoom: zoom,
                  );

                case 3:
                  return _StatCard(
                    key: const Key(
                      'core-stat-happiness',
                    ),
                    label: 'Happiness',
                    value:
                        player.stats.happiness,
                    icon: Icons.sentiment_satisfied,
                    zoom: zoom,
                  );

                case 4:
                  return _StatCard(
                    key: const Key(
                      'core-stat-willpower',
                    ),
                    label: 'Willpower',
                    value:
                        player.stats.willpower,
                    icon: Icons.shield_outlined,
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
                    label: 'Creativity',
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
                    value: player.stats.luck,
                    icon: Icons.auto_awesome,
                    zoom: zoom,
                  );

                default:
                  return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    double zoom,
  ) {
    return _BottomNavigation(
      zoom: zoom,
      isProcessing: _isProcessingTurn,
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
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: _everyLifeCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.dividerColor.withValues(
            alpha: 0.55,
          ),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
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
    double s(double value) => value * zoom;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final progress =
        value.clamp(0, 100).toDouble();

    return _ResponsiveCard(
      padding: EdgeInsets.fromLTRB(
        s(5),
        s(5),
        s(5),
        s(4),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          SizedBox(
            height: s(19),
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: s(15),
                    color: primary,
                  ),
                  SizedBox(width: s(3)),
                  Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(width: s(4)),
                  Text(
                    value.toString(),
                    maxLines: 1,
                    softWrap: false,
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: s(3)),
          ClipRRect(
            borderRadius: BorderRadius.circular(s(4)),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: s(3),
              backgroundColor:
                  primary.withValues(alpha: 0.12),
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                primary,
              ),
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
  final Future<void> Function() onAgeUpTap;
  final VoidCallback onLifeTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    return SizedBox(
      height: s(68),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            height: s(56),
            color: _everyLifeSurfaceColor,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: s(4),
                vertical: s(2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavigationItem(
                      assetPath:
                          'assets/icons/career.svg',
                      label: 'Career',
                      zoom: zoom,
                      enabled: !isProcessing,
                      onTap: onCareerTap,
                    ),
                  ),
                  Expanded(
                    child: _NavigationItem(
                      assetPath:
                          'assets/icons/assets.svg',
                      label: 'Assets',
                      zoom: zoom,
                      enabled: !isProcessing,
                      onTap: onAssetsTap,
                    ),
                  ),
                  SizedBox(width: s(68)),
                  Expanded(
                    child: _NavigationItem(
                      assetPath:
                          'assets/icons/life.svg',
                      label: 'Life',
                      zoom: zoom,
                      enabled: !isProcessing,
                      onTap: onLifeTap,
                    ),
                  ),
                  Expanded(
                    child: _NavigationItem(
                      assetPath:
                          'assets/icons/more.svg',
                      label: 'More',
                      zoom: zoom,
                      enabled: !isProcessing,
                      onTap: onMoreTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -s(20),
            child: _AgeUpButton(
              zoom: zoom,
              enabled: !isProcessing,
              onTap: onAgeUpTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeUpButton extends StatelessWidget {
  const _AgeUpButton({
    required this.zoom,
    required this.enabled,
    required this.onTap,
  });

  final double zoom;
  final bool enabled;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    return Material(
      key: const Key('bottom-nav-age-up'),
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () async {
                await onTap();
              }
            : null,
        customBorder: const CircleBorder(),
        child: Ink(
          width: s(70),
          height: s(70),
          decoration: BoxDecoration(
            color: _everyLifeSurfaceColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: _everyLifeAgeUpBorder,
              width: s(1.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.18,
                ),
                blurRadius: s(5),
                offset: Offset(0, s(3)),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: s(50),
              height: s(50),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _everyLifeAgeUpBorder.withValues(
                    alpha: 0.35,
                  ),
                  width: s(1),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(s(7)),
                child: Opacity(
                  opacity: enabled ? 1.0 : 0.38,
                  child: Image.asset(
                    'assets/icons/age_up.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.assetPath,
    required this.label,
    required this.zoom,
    required this.enabled,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final double zoom;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(s(8)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: s(2),
          vertical: s(2),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: enabled ? 1.0 : 0.38,
              child: SvgPicture.asset(
                assetPath,
                width: s(23),
                height: s(23),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: s(2)),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
