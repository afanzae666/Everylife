import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:everylife/core/money/money.dart';

import '../../core/money/currency_formatter.dart';
import '../../core/money/fixed_exchange_rates.dart';
import '../../core/result/result.dart';
import '../../data/services/character_palette_service.dart';
import '../../data/settings/auto_save_settings.dart';
import '../../domain/character/life_stage.dart';
import '../../domain/world/country_catalog.dart';
import '../../simulation/engine/simulation_engine.dart';
import '../../simulation/events/life_effect_applier.dart';
import '../../domain/event/life_event.dart';
import '../../domain/character/character_stats.dart';
import '../widgets/character_avatar.dart';
import '../widgets/core_stat_bars.dart';
import '../widgets/life_event_dialogs.dart';
import 'assets_screen.dart';
import 'career_screen.dart';
import 'character_profile_screen.dart';
import 'life_screen.dart';
import 'more_screen.dart';
import 'menu_screen.dart';
import 'save_load_screen.dart';
import 'settings_screen.dart';

Future<void> _defaultUiScaleChanged(double value) async {}

enum NewLifeRequestAction {
  saveCurrentLife,
  startWithoutSaving,
  cancel,
}

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.engine,
    this.onUiScaleChanged = _defaultUiScaleChanged,
    this.uiScaleController,
    this.onNewLifeRequested,
    this.onNewLifeCreationRequested,
    super.key,
  });

  final SimulationEngine engine;
  final Future<void> Function(double value) onUiScaleChanged;
  final ValueNotifier<double>? uiScaleController;

  final Future<NewLifeRequestAction?> Function()?
      onNewLifeRequested;

  final VoidCallback? onNewLifeCreationRequested;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  SimulationEngine get engine => widget.engine;

  late final ValueNotifier<double> _uiScaleController;
  late final bool _ownsUiScaleController;
  late final ValueNotifier<bool> _autoSaveController;
  late final AutoSaveSettings _autoSaveSettings;
  late final Future<CharacterPaletteService>
      _characterPaletteFuture;

  bool _autoSaveSettingReady = false;
  bool _isProcessingTurn = false;
  bool _isShowingLifeDialog = false;

  final ScrollController _lifeEventsScrollController =
      ScrollController();

  @override
  void initState() {
    super.initState();

    _characterPaletteFuture =
        CharacterPaletteService.load();

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

    // A loaded save may be waiting on a decision or already be over.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleLifeFlow();
    });
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

  void _showTurnMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows the pending decision or the ending dialog, if there is one.
  Future<void> _handleLifeFlow() async {
    if (_isShowingLifeDialog || !mounted) {
      return;
    }

    _isShowingLifeDialog = true;

    try {
      while (mounted) {
        final progress = engine.state.lifeProgress;

        if (progress.ending != null) {
          final player = engine.state.player;
          final startNew = await showLifeEndedDialog(
            context,
            name: player.fullName,
            ending: progress.ending!,
            netWorthText: _formatMoney(
              Money.fromMinorUnits(progress.ending!.netWorthMinorUnits),
              currencyCode: _getCurrencyCode(player),
            ),
          );

          if (startNew && mounted) {
            widget.onNewLifeCreationRequested?.call();
          }

          return;
        }

        if (progress.pending == null) {
          return;
        }

        final event = engine.pendingLifeEvent;

        if (event == null) {
          // Unknown event id: this clears it so the game cannot get stuck.
          engine.resolveLifeChoice('');
          setState(() {});
          continue;
        }

        final choiceId = await showLifeDecisionDialog(
          context,
          event: event,
          description: engine.pendingDescription,
          canAfford: engine.canAffordChoice,
          costLabel: _choiceCostLabel,
        );

        if (!mounted || choiceId == null) {
          return;
        }

        final result = engine.resolveLifeChoice(choiceId);

        if (result case Failure<LifeChoiceResult>(:final message)) {
          _showTurnMessage(message);
          continue;
        }

        setState(() {});
        _scrollLifeEventsToBottom();

        if (result case Success<LifeChoiceResult>(:final value)) {
          await showLifeResultDialog(context, value);
        }

        if (!mounted) {
          return;
        }

        if (_autoSaveController.value) {
          final saveResult = await engine.save();

          if (saveResult case Failure<void>(:final message)) {
            _showTurnMessage('Auto-save failed: $message');
          }
        }
      }
    } finally {
      _isShowingLifeDialog = false;
    }
  }

  Future<void> _ageUp() async {
    if (_isProcessingTurn) {
      return;
    }

    final lifeProgress = engine.state.lifeProgress;

    if (lifeProgress.ending != null || lifeProgress.pending != null) {
      await _handleLifeFlow();
      return;
    }

    setState(() {
      _isProcessingTurn = true;
    });

    final result = engine.ageUp();

    if (!mounted) {
      return;
    }

    if (result case Failure<void>(:final message)) {
      setState(() {
        _isProcessingTurn = false;
      });
      _showTurnMessage('Unable to age up: $message');
      return;
    }

    setState(() {});

    _scrollLifeEventsToBottom();

    if (_autoSaveController.value) {
      final saveResult = await engine.save();

      if (!mounted) {
        return;
      }

      if (saveResult case Failure<void>(:final message)) {
        _showTurnMessage('Auto-save failed: $message');
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessingTurn = false;
    });

    await _handleLifeFlow();
  }

  Future<bool> _openSaveManager({
    bool isNewLifeFlow = false,
  }) async {
    if (_isProcessingTurn) {
      return false;
    }

    final screenSize = MediaQuery.sizeOf(context);

    final saved = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.32,
      ),
      builder: (dialogContext) {
        final dialogWidth = screenSize.width * 0.92;
        final dialogHeight = screenSize.height * 0.82;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: SaveLoadScreen(
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
                _handleLifeFlow();
              },
              isNewLifeFlow: isNewLifeFlow,
            ),
          ),
        );
      },
    );

    return saved == true;
  }

  Future<void> _openCharacterProfile() async {
    if (_isProcessingTurn) {
      return;
    }

    final screenSize = MediaQuery.sizeOf(context);

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.32,
      ),
      builder: (dialogContext) {
        final dialogWidth = screenSize.width * 0.92;
        final dialogHeight = screenSize.height * 0.82;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: CharacterProfileScreen(
              character: engine.state.player,
              currentYear: engine.state.clock.currentYear,
              uiScaleController: _uiScaleController,
              onViewAssets: () {
                Navigator.of(dialogContext).pop();

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
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _openMenu() async {
    if (_isProcessingTurn) {
      return;
    }

    final action =
        await Navigator.of(context).push<MenuScreenAction>(
      MaterialPageRoute<MenuScreenAction>(
        builder: (_) => MenuScreen(
          zoom: _uiScaleController.value,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    switch (action) {
      case MenuScreenAction.settings:
        _openSettings();
        break;

      case MenuScreenAction.newLife:
        final requestAction =
            await widget.onNewLifeRequested?.call();

        if (!mounted) {
          return;
        }

        switch (requestAction) {
          case NewLifeRequestAction.saveCurrentLife:
            final saved = await _openSaveManager(
              isNewLifeFlow: true,
            );

            if (!mounted) {
              return;
            }

            if (saved) {
              widget.onNewLifeCreationRequested?.call();
            }
            break;

          case NewLifeRequestAction.startWithoutSaving:
            widget.onNewLifeCreationRequested?.call();
            break;

          case NewLifeRequestAction.cancel:
          case null:
            break;
        }
        break;

      case null:
        break;
    }
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

  /// The price shown under a choice that costs money, in the player's
  /// currency (null when the choice is free).
  String? _choiceCostLabel(LifeChoice choice) {
    if (choice.requiresMoneyBase <= 0) {
      return null;
    }

    final scaled = LifeEffectApplier.scaleMoney(
      engine.state,
      choice.requiresMoneyBase,
    );

    return 'Cost: ${_formatMoney(
      Money.fromMinorUnits(scaled),
      currencyCode: _getCurrencyCode(engine.state.player),
    )}';
  }

  /// Ages 0-5: the first tab shows who I am instead of a school or a job.
  Future<void> _openInfantInfo() async {
    if (_isProcessingTurn) {
      return;
    }

    final player = engine.state.player;
    final age = player.ageAt(engine.state.clock.currentYear);
    final stats = player.stats;
    final household = engine.state.familyHousehold;
    final theme = Theme.of(context);

    Widget row(String label, int value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Text('$value'),
            ],
          ),
        );

    final parents = [
      if (household != null)
        for (final parent in household.parents)
          Text(
            '${parent.isAlive ? '' : '(deceased) '}${parent.fullName}',
            textAlign: TextAlign.center,
          ),
    ];

    await showTapToCloseOverlay(
      context,
      title: player.fullName,
      text: '',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Age $age · ${_formatLifeStage(LifeStageAge.fromAge(age))}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          row('Health', stats.health),
          row('Happiness', stats.happiness),
          row('Intelligence', stats.intelligence),
          row('Fitness', stats.fitness),
          row('Charisma', stats.charisma),
          row('Creativity', stats.creativity),
          if (parents.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'My family',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            ...parents,
          ],
        ],
      ),
    );
  }

  void _openCareerPage() {
    if (_isProcessingTurn) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CareerScreen(
          engine: engine,
          zoom: _uiScaleController.value,
          onChanged: () async {
            if (mounted) {
              setState(() {});
            }

            if (_autoSaveController.value) {
              await engine.save();
            }
          },
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
  parents: engine.state.familyHousehold?.parents ?? const [],
  siblings: engine.state.familyHousehold?.siblings ?? const [],
  playerBirthYear: engine.state.player.birthYear,
  currentYear: engine.state.clock.currentYear,
  onNpcInteraction: ({required npcId, required action}) {
    final result = engine.interactWithNpc(npcId: npcId, action: action);
    if (result.isSuccess && mounted) setState(() {});
    return result;
  },
  isNpcLocked: engine.hasInteractedThisYear,
  readCurrentParents: () => engine.state.familyHousehold?.parents ?? const [],
  readCurrentSiblings: () => engine.state.familyHousehold?.siblings ?? const [],
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

    String _getCurrencyCode(dynamic player) {
    final countryCode = player.location?.countryCode ?? '';
    final country = CountryCatalog.findByCode(countryCode);
    final currencyCode = country?.currencyCode ?? 'USD';

    // Jangan meminta konversi dengan kurs yang belum tersedia.
    // Gunakan USD sebagai fallback agar layar tidak crash.
    if (FixedExchangeRates.snapshot.rateFor(currencyCode) == null) {
      return 'USD';
    }

    return currencyCode;
  }

  String _formatMoney(
    Money amount, {
    required String currencyCode,
  }) {
    return CurrencyFormatter.format(
      amount,
      currencyCode: currencyCode,
    );
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

    return ValueListenableBuilder<double>(
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
    );
  }

  /// Height of the bottom navigation bar (before zoom).
  static const double _navigationHeight = 64;

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                : () {
                    _openSaveManager();
                  },
            icon: Icon(
              Icons.folder_copy_outlined,
              size: s(24),
            ),
          ),
          IconButton(
            tooltip: 'Menu',
            onPressed: _isProcessingTurn
                ? null
                : _openMenu,
            icon: Icon(
              Icons.menu,
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
            SizedBox(height: 0),
            Expanded(
              child: Padding(
                // The life log floats a little above the navigation bar.
                padding: EdgeInsets.only(bottom: 4 * zoom),
                child: _buildLifeEventsCard(
                  context,
                  zoom,
                  player,
                  events,
                ),
              ),
            ),
            // The navigation bar sits on top of the stat card. A Stack lets
            // the big Age Up button overlap the card below it.
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: _navigationHeight * zoom),
                  child: _buildCoreStatsCard(
                    context,
                    zoom,
                    player,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomNavigation(
                    context,
                    zoom,
                  ),
                ),
              ],
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('character-card'),
        onTap: _isProcessingTurn
            ? null
            : _openCharacterProfile,
        borderRadius: BorderRadius.zero,
        child: _ResponsiveCard(
          padding: EdgeInsets.all(s(3)),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              FutureBuilder<CharacterPaletteService>(
                future: _characterPaletteFuture,
                builder: (
                  context,
                  snapshot,
                ) {
                  if (snapshot.connectionState !=
                      ConnectionState.done) {
                    return SizedBox(
                      key: const Key('character-avatar'),
                      width: s(56),
                      height: s(70),
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError ||
                      snapshot.data == null) {
                    return SizedBox(
                      key: const Key('character-avatar'),
                      width: s(56),
                      height: s(70),
                    );
                  }

                  final palette = snapshot.data!;

                  final skinColor =
                      palette.skinColor(
                    player.appearance.skinTone,
                  );

                  final eyeColor =
                      palette.eyeColor(
                    player.appearance.eyeColor,
                  );

                  final hairColor =
                      palette.hairColor(
                    player.appearance.hairColor,
                  );

                  if (skinColor == null ||
                      eyeColor == null ||
                      hairColor == null) {
                    return SizedBox(
                      key: const Key('character-avatar'),
                      width: s(56),
                      height: s(70),
                    );
                  }

                  return CharacterAvatar(
                    key: const Key('character-avatar'),
                    character: player,
                    currentYear:
                        state.clock.currentYear,
                    size: s(56),
                    skinColor: skinColor,
                    eyeColor: eyeColor,
                    hairColor: hairColor,
                  );
                },
              ),
              SizedBox(width: s(6)),
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
                    SizedBox(height: s(1)),
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
              SizedBox(width: s(6)),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                                        child: Text(
                      _formatMoney(
                        player.money,
                        currencyCode: _getCurrencyCode(player),
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      softWrap: false,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(
                            fontSize:
                                (Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .fontSize ??
                                        14) *
                                    1.25,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

    final groupedEvents =
        eventsByYear.entries.toList();

    return _ResponsiveCard(
      padding: EdgeInsets.fromLTRB(
        s(4),
        s(3),
        s(4),
        s(3),
      ),
      child: groupedEvents.isEmpty
          ? const Center(
              child: Text(
                'No events yet.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              controller:
                  _lifeEventsScrollController,
              padding: EdgeInsets.zero,
              itemCount:
                  groupedEvents.length,
              separatorBuilder: (_, __) =>
                  SizedBox(
                height: s(7),
              ),
              itemBuilder: (
                context,
                index,
              ) {
                final yearGroup =
                    groupedEvents[index];
                final year = yearGroup.key;
                final yearEvents =
                    yearGroup.value;
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
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .primary,
                          ),
                        ),
                        SizedBox(width: s(7)),
                        Expanded(
                          child: Text(
                            'Age $eventAge',
                            style: Theme.of(
                              context,
                            )
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
                              SizedBox(
                                height: s(2),
                              ),
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
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
                                    yearEvents[
                                            eventIndex]
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
    return _ResponsiveCard(
      padding: EdgeInsets.zero,
      child: CoreStatBars(
        stats: player.stats as CharacterStats,
        zoom: zoom,
        onTap: _openOtherTraits,
      ),
    );
  }

  /// The traits that are not on the main screen. Luck stays hidden on
  /// purpose, so lucky and unlucky moments keep their mystery.
  Future<void> _openOtherTraits() async {
    final stats = engine.state.player.stats;
    final theme = Theme.of(context);

    Widget row(String label, int value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Text('$value%', style: theme.textTheme.bodyLarge),
            ],
          ),
        );

    await showTapToCloseOverlay(
      context,
      title: 'My Traits',
      text: '',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row('Fitness', stats.fitness),
          row('Willpower', stats.willpower),
          row('Charisma', stats.charisma),
          row('Creativity', stats.creativity),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    double zoom,
  ) {
    final age = engine.state.player.ageAt(engine.state.clock.currentYear);

    // Ages 0-5 show the player's info, 6-17 school, 18+ the occupation.
    final firstItem = age < 6
        ? const _NavSlot(label: 'Infant', icon: Icons.child_care_rounded)
        : age < 18
            ? const _NavSlot(label: 'School', icon: Icons.school_rounded)
            : const _NavSlot(label: 'Occupation', icon: Icons.work_rounded);

    return _BottomNavigation(
      zoom: zoom,
      isProcessing: _isProcessingTurn,
      firstSlot: firstItem,
      onCareerTap: () {
        if (age < 6) {
          _openInfantInfo();
        } else {
          _openCareerPage();
        }
      },
      onAssetsTap: _openAssetsTab,
      onAgeUpTap: _ageUp,
      onLifeTap: _openLifePage,
      onMoreTap: _openMorePage,
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
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
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

class _BottomNavigation
    extends StatelessWidget {
  const _BottomNavigation({
    required this.zoom,
    required this.isProcessing,
    required this.firstSlot,
    required this.onCareerTap,
    required this.onAssetsTap,
    required this.onAgeUpTap,
    required this.onLifeTap,
    required this.onMoreTap,
  });

  final double zoom;
  final bool isProcessing;
  final _NavSlot firstSlot;
  final VoidCallback onCareerTap;
  final VoidCallback onAssetsTap;
  final Future<void> Function() onAgeUpTap;
  final VoidCallback onLifeTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.outlineVariant;

    Widget divider() => SizedBox(
          width: 1,
          child: ColoredBox(color: lineColor),
        );

    Widget item({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: _NavigationItem(
          icon: icon,
          label: label,
          zoom: zoom,
          enabled: !isProcessing,
          onTap: onTap,
        ),
      );
    }

    return SizedBox(
      height: s(_GameScreenState._navigationHeight),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // The bar, with lines above and below it.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.symmetric(
                  horizontal: BorderSide(color: lineColor),
                ),
              ),
            ),
          ),

          // Icons with a line between each of them.
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              item(
                icon: firstSlot.icon,
                label: firstSlot.label,
                onTap: onCareerTap,
              ),
              divider(),
              item(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Assets',
                onTap: onAssetsTap,
              ),
              divider(),
              SizedBox(width: s(88)),
              divider(),
              item(
                icon: Icons.favorite_rounded,
                label: 'Life',
                onTap: onLifeTap,
              ),
              divider(),
              item(
                icon: Icons.more_horiz_rounded,
                label: 'More',
                onTap: onMoreTap,
              ),
            ],
          ),

          // Age Up sits in the middle of the bar and may spill outside it.
          _AgeUpButton(
            zoom: zoom,
            enabled: !isProcessing,
            onTap: onAgeUpTap,
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

    final theme = Theme.of(context);

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
        child: Opacity(
          opacity: enabled ? 1.0 : 0.38,
          child: Container(
            width: s(80),
            height: s(80),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: s(5),
                  offset: Offset(0, s(3)),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _AgeUpPainter(
                color: theme.colorScheme.primary,
                background: theme.colorScheme.surface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the Age Up button in code: a thick ring with three light slots and
/// a big four-point star surrounded by four small ones.
class _AgeUpPainter extends CustomPainter {
  const _AgeUpPainter({
    required this.color,
    required this.background,
  });

  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final light = Paint()
      ..color = background
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Ring: a solid disc with a lighter disc inside it.
    canvas.drawCircle(center, radius * 0.96, fill);
    canvas.drawCircle(center, radius * 0.77, light);

    // Three light slots cut into the ring.
    final slot = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.09
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final slotRect = Rect.fromCircle(center: center, radius: radius * 0.87);

    void arc(double startDegrees, double endDegrees) {
      canvas.drawArc(
        slotRect,
        startDegrees * math.pi / 180,
        (endDegrees - startDegrees) * math.pi / 180,
        false,
        slot,
      );
    }

    arc(245, 295); // top
    arc(135, 185); // lower left
    arc(355, 405); // lower right

    // Stars.
    _star(canvas, center, radius * 0.36, fill);
    _star(canvas, center + Offset(0, -radius * 0.55), radius * 0.09, fill);
    _star(canvas, center + Offset(0, radius * 0.55), radius * 0.09, fill);
    _star(canvas, center + Offset(-radius * 0.53, 0), radius * 0.09, fill);
    _star(canvas, center + Offset(radius * 0.53, 0), radius * 0.09, fill);
  }

  /// A four-point star with curved (concave) sides.
  void _star(Canvas canvas, Offset center, double r, Paint paint) {
    final k = r * 0.2;
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(center.dx + k, center.dy - k, center.dx + r, center.dy)
      ..quadraticBezierTo(center.dx + k, center.dy + k, center.dx, center.dy + r)
      ..quadraticBezierTo(center.dx - k, center.dy + k, center.dx - r, center.dy)
      ..quadraticBezierTo(center.dx - k, center.dy - k, center.dx, center.dy - r)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_AgeUpPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.background != background;
  }
}

/// Icon and label of the first bottom tab. It changes with the player's age.
class _NavSlot {
  const _NavSlot({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// One bottom tab: a white icon on a round green background, like BitLife.
class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.zoom,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final double zoom;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled ? onTap : null,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: s(2),
          vertical: s(2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: enabled ? 1.0 : 0.38,
              child: Container(
                width: s(28),
                height: s(28),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: s(17),
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: s(2)),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
