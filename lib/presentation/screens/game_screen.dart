import 'dart:ui' as ui;
import 'package:everylife/core/money/game_currency.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:everylife/core/money/money.dart';

import '../../core/money/currency_formatter.dart';
import '../../core/result/result.dart';
import '../../data/services/character_palette_service.dart';
import '../../domain/character/life_stage.dart';
import '../../domain/world/country_catalog.dart';
import '../../simulation/engine/simulation_engine.dart';
import '../../simulation/events/life_effect_applier.dart';
import '../../domain/event/life_event.dart';
import '../../domain/character/character_stats.dart';
import '../../simulation/school/school_appearance.dart';
import '../widgets/npc_avatar.dart';
import '../widgets/person_avatar.dart';
import '../widgets/themed_app_bar.dart';
import '../widgets/themed_cards.dart';
import '../widgets/slide_up_route.dart';
import '../widgets/character_avatar.dart';
import '../widgets/core_stat_bars.dart';
import '../widgets/life_event_dialogs.dart';
import '../widgets/life_labels.dart';
import 'assets_screen.dart';
import 'career_screen.dart';
import 'character_profile_screen.dart';
import '../../domain/character/fertility.dart';
import '../../domain/character/gender.dart';
import '../widgets/animated_dialog.dart';
import '../widgets/club_widgets.dart';
import 'life_screen.dart';
import 'more_screen.dart';
import 'menu_screen.dart';
import 'life_storage_screen.dart';
import 'settings_screen.dart';
import 'time_machine_screen.dart';

Future<void> _defaultUiScaleChanged(double value) async {}

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.engine,
    this.onUiScaleChanged = _defaultUiScaleChanged,
    this.uiScaleController,
    this.onNewLifeCreationRequested,
    super.key,
  });

  final SimulationEngine engine;
  final Future<void> Function(double value) onUiScaleChanged;
  final ValueNotifier<double>? uiScaleController;

  final VoidCallback? onNewLifeCreationRequested;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  SimulationEngine get engine => widget.engine;

  late final ValueNotifier<double> _uiScaleController;
  late final bool _ownsUiScaleController;
  late final Future<CharacterPaletteService>
      _characterPaletteFuture;

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

    _lifeEventsScrollController.dispose();

    super.dispose();
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
            await _startNewLife();
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

        final npcAvatar = _eventNpcAvatar(event);

        final choiceId = await showLifeDecisionDialog(
          context,
          avatar: npcAvatar,
          fillText: (text) => LifeText.fillPending(
            text,
            engine.state.lifeProgress.pending,
          ),
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
          await showLifeResultDialog(context, value, avatar: npcAvatar);
        }

        if (mounted) await _offerFriendship();

        if (!mounted) {
          return;
        }

        final saveResult = await engine.save();

        if (saveResult case Failure<void>(:final message)) {
          _showTurnMessage('Auto-save failed: $message');
        }
      }
    } finally {
      _isShowingLifeDialog = false;
    }
  }

  /// Announces a baby born on this birthday.
  Future<void> _announceNewborn() async {
    final baby = engine.takeNewborn();

    if (baby == null) return;

    final year = engine.state.clock.currentYear;

    await showTapToCloseOverlay(
      context,
      title: 'Baby Born',
      emoji: '👶',
      avatar: NpcAvatar(
        character: SchoolAppearance.characterForChild(baby),
        currentYear: year,
        size: 112,
      ),
      text: baby.gender == Gender.female
          ? 'It is a girl! Welcome to the world, ${baby.fullName}.'
          : 'It is a boy! Welcome to the world, ${baby.fullName}.',
    );
  }

  /// Asks whether to become friends with someone an event just introduced.
  Future<void> _offerFriendship() async {
    final person = engine.friendOffer;

    if (person == null) return;

    final theme = Theme.of(context);
    final avatar = NpcAvatar(
      character: SchoolAppearance.characterFor(person),
      currentYear: engine.state.clock.currentYear,
      size: 112,
    );

    final yes = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) => ThemedDialog(
        title: 'NEW FRIEND?',
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            key: const Key('friend-offer'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox(
                  width: 84,
                  height: 105,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(width: 112, height: 140, child: avatar),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Do I want to be friends with ${person.fullName}?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              FilledButton(
                key: const Key('friend-offer-yes'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('YES, LET US BE FRIENDS'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('friend-offer-no'),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('NO, THANKS'),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (yes != true) {
      engine.declineFriendOffer();

      return;
    }

    final result = engine.acceptFriendOffer();

    setState(() {});

    if (result case Success<String>(:final value)) {
      await showTapToCloseOverlay(
        context,
        title: 'New Friend',
        emoji: '🤝',
        avatar: avatar,
        text: value,
      );
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

    final saveResult = await engine.save();

    if (!mounted) {
      return;
    }

    if (saveResult case Failure<void>(:final message)) {
      _showTurnMessage('Auto-save failed: $message');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessingTurn = false;
    });

    await _handleLifeFlow();

    if (mounted) await _announceNewborn();

    // A club promotion earned on this birthday.
    if (mounted && engine.state.lifeProgress.ending == null) {
      await showClubPromotionIfAny(context, engine);
    }
  }

  /// Opens Life Storage. Returns true when a different life was loaded.
  Future<bool> _openLifeStorage({
    bool isFull = false,
  }) async {
    if (_isProcessingTurn) {
      return false;
    }

    final loaded = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => LifeStorageScreen(
          zoom: _uiScaleController.value,
          activeSlot: engine.activeSlot,
          isFull: isFull,
          onRead: engine.readSaveSlot,
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
        ),
      ),
    );

    return loaded == true;
  }

  /// Starts creating a new life. Every life needs its own storage slot, so
  /// when Life Storage is full the player must delete one first.
  Future<void> _startNewLife() async {
    var freeSlot = await engine.firstFreeSlot();

    if (!mounted) {
      return;
    }

    if (freeSlot == null) {
      final openStorage = await showAnimatedDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            key: const Key('life-storage-full-dialog'),
            title: const Text('Life Storage is full'),
            content: const Text(
              'Every life needs its own slot. Delete a life to make room '
              'for a new one.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                key: const Key('open-life-storage'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('OPEN LIFE STORAGE'),
              ),
            ],
          );
        },
      );

      if (!mounted || openStorage != true) {
        return;
      }

      await _openLifeStorage(isFull: true);

      if (!mounted) {
        return;
      }

      freeSlot = await engine.firstFreeSlot();

      if (!mounted || freeSlot == null) {
        return;
      }
    }

    widget.onNewLifeCreationRequested?.call();
  }

  Future<void> _openCharacterProfile() async {
    if (_isProcessingTurn) {
      return;
    }

    final screenSize = MediaQuery.sizeOf(context);

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );

        return BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 4 * animation.value,
            sigmaY: 4 * animation.value,
          ),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: curved, child: child),
          ),
        );
      },
      pageBuilder: (dialogContext, _, __) {
        return SafeArea(
          child: Center(
            child: Material(
              type: MaterialType.transparency,
              child: SizedBox(
                width: screenSize.width * 0.94,
                child: CharacterProfileScreen(
                  character: engine.state.player,
                  currentYear: engine.state.clock.currentYear,
                  uiScaleController: _uiScaleController,
                  occupation: occupationLabel(engine.state),
                  onViewAssets: () {
                    Navigator.of(dialogContext).pop();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || _isProcessingTurn) {
                        return;
                      }

                      _openAssetsTab();
                    });
                  },
                ),
              ),
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

      case MenuScreenAction.lifeStorage:
        await _openLifeStorage();
        break;

      case MenuScreenAction.newLife:
        await _startNewLife();
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

  /// The character profile card shown at the top of every page.
  Widget _pageHeader(BuildContext context) {
    final state = engine.state;
    final player = state.player;
    final age = player.ageAt(state.clock.currentYear);

    return _buildCharacterCard(
      context,
      _uiScaleController.value,
      state,
      player,
      age,
      _formatLifeStage(LifeStageAge.fromAge(age)),
    );
  }

  void _openAssetsTab() {
    if (_isProcessingTurn) {
      return;
    }

    Navigator.of(context).push(
      slideUpRoute<void>(
        (_) => AssetsScreen(
          player: engine.state.player,
          zoom: _uiScaleController.value,
          headerBuilder: _pageHeader,
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
      emoji: '🪪',
      avatar: NpcAvatar(
        character: player,
        currentYear: engine.state.clock.currentYear,
        size: 112,
      ),
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
      slideUpRoute<void>(
        (_) => CareerScreen(
          engine: engine,
          zoom: _uiScaleController.value,
          headerBuilder: _pageHeader,
          onChanged: () async {
            if (mounted) {
              setState(() {});
              _scrollLifeEventsToBottom();
            }

            await engine.save();
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
      slideUpRoute<void>(
        (_) => LifeScreen(
  headerBuilder: _pageHeader,
  zoom: _uiScaleController.value,
  parents: engine.state.familyHousehold?.parents ?? const [],
  siblings: engine.state.familyHousehold?.siblings ?? const [],
  playerBirthYear: engine.state.player.birthYear,
  currentYear: engine.state.clock.currentYear,
  onNpcInteraction: ({required npcId, required action}) {
    final result = engine.interactWithNpc(npcId: npcId, action: action);
    if (result.isSuccess && mounted) {
      setState(() {});
      _scrollLifeEventsToBottom();
    }
    return result;
  },
  readCurrentParents: () => engine.state.familyHousehold?.parents ?? const [],
  readCurrentSiblings: () => engine.state.familyHousehold?.siblings ?? const [],
  friends: engine.state.lifeProgress.friends,
  readCurrentFriends: () => engine.state.lifeProgress.friends,
  love: engine.state.lifeProgress.love,
  readCurrentLove: () => engine.state.lifeProgress.love,
),
      ),
    );
  }


  Future<void> _openTimeMachine() async {
    if (_isProcessingTurn) {
      return;
    }

    final travelled = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TimeMachineScreen(
          zoom: _uiScaleController.value,
          headerBuilder: _pageHeader,
          readAges: () => engine.rewindableAges,
          onRewind: engine.rewindToAge,
        ),
      ),
    );

    if (!mounted || travelled != true) {
      return;
    }

    // Leave the More page too, so the player lands back on the life log.
    Navigator.of(context).popUntil((route) => route.isFirst);

    setState(() {});
    _scrollLifeEventsToBottom();

    final saveResult = await engine.save();

    if (!mounted) {
      return;
    }

    if (saveResult case Failure<void>(:final message)) {
      _showTurnMessage('Auto-save failed: $message');
    }

    await _handleLifeFlow();
  }

  void _openMorePage() {
    if (_isProcessingTurn) {
      return;
    }

    Navigator.of(context).push(
      slideUpRoute<void>(
        (_) => MoreScreen(
          zoom: _uiScaleController.value,
          headerBuilder: _pageHeader,
          onTimeMachine: _openTimeMachine,
        ),
      ),
    );
  }

    String _getCurrencyCode(dynamic player) {
    final countryCode = player.location?.countryCode ?? '';
    final country = CountryCatalog.findByCode(countryCode);
    return GameCurrency.forCountryCurrency(country?.currencyCode);
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
  static const double _navigationHeight = 74;

  /// How far the Age Up button rises above the navigation bar.
  static const double _ageUpRise = 10;

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
      appBar: ThemedAppBar(
        zoom: zoom,
        leading: BarIconButton(
          zoom: zoom,
          icon: Icons.emoji_events_rounded,
          tooltip: 'Achievements',
          onPressed: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Achievements are coming soon.'),
                ),
              );
          },
        ),
        titleWidget: Image.asset(
          'assets/images/everylife_logo.png',
          height: s(38),
          fit: BoxFit.contain,
        ),
        actions: [
          BarIconButton(
            zoom: zoom,
            icon: Icons.menu,
            tooltip: 'Menu',
            onPressed: () {
              if (!_isProcessingTurn) _openMenu();
            },
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
              child: _buildLifeEventsCard(
                context,
                zoom,
                player,
                events,
              ),
            ),
            // The stat card sits above the navigation bar, which is the very
            // last thing on the screen. The Age Up button rises a little above
            // the bar, over the bottom edge of the stat card.
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: _navigationHeight * zoom),
                  child: _buildCoreStatsCard(
                    context,
                    zoom,
                    player,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
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

  /// A line of text with a small emoji in front (a country flag or a job
  /// picture), at the same size as the text.
  Widget _flagLine(String text, String flag, TextStyle style) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (flag.isNotEmpty) ...[
          Text(flag, style: style),
          SizedBox(width: (style.fontSize ?? 14) * 0.3),
        ],
        Text(text, style: style, maxLines: 1, softWrap: false),
      ],
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

    final flag = countryFlag(player.location?.countryCode as String?);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('character-card'),
        onTap: _isProcessingTurn
            ? null
            : _openCharacterProfile,
        borderRadius: BorderRadius.zero,
        child: _HeaderFrame(
          zoom: zoom,
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              _AvatarPlate(
                zoom: zoom,
                child: FutureBuilder<CharacterPaletteService>(
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
              ),
              SizedBox(width: s(8)),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Long names shrink to fit instead of being cut off.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: _flagLine(
                        player.name,
                        flag,
                        Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontSize: (Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .fontSize ??
                                      16) *
                                  0.9,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    SizedBox(height: s(3)),
                    _HeaderTag(
                      zoom: zoom,
                      child: _flagLine(
                        occupationLabel(state),
                        occupationEmoji(state),
                        Theme.of(context).textTheme.labelSmall!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    SizedBox(height: s(3)),
                    Row(
                      children: [
                        _HeaderTag(
                          zoom: zoom,
                          filled: true,
                          child: Text(lifeStageLabel.toUpperCase()),
                        ),
                        SizedBox(width: s(4)),
                        _HeaderTag(
                          zoom: zoom,
                          child: Text('AGE $age'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: s(6)),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'CASH',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                  ),
                  SizedBox(height: s(2)),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: s(150)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: _MoneyPill(
                        zoom: zoom,
                        child: Text(
                          _formatMoney(
                            player.money,
                            currencyCode: _getCurrencyCode(player),
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          softWrap: false,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: (Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .fontSize ??
                                        14) *
                                    0.95,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
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
        0,
      ),
      child: Column(
        children: [
          SectionDivider(title: 'LIFE LOG', zoom: zoom),
          Expanded(
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
              // Only the text floats: 11px of air above the navigation bar.
              padding: EdgeInsets.only(bottom: s(11)),
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AgePill(text: 'Age $eventAge', zoom: zoom),
                    ),
                    SizedBox(height: s(2)),
                    Container(
                      margin: EdgeInsets.only(left: s(12), top: s(2)),
                      padding: EdgeInsets.only(left: s(8)),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
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
          ),
        ],
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
    final player = engine.state.player;
    final stats = player.stats;
    final theme = Theme.of(context);
    final age = player.ageAt(engine.state.clock.currentYear);
    final fertility = Fertility.effective(stats.fertility, age, player.gender);

    Widget row(String label, int value, {Key? key}) => Padding(
          key: key,
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(child: PipBar(value: value / 100, height: 9)),
              SizedBox(
                width: 48,
                child: Text(
                  '$value%',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        );

    await showTapToCloseOverlay(
      context,
      title: 'My Traits',
      emoji: '💪',
      text: '',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row('Fitness', stats.fitness),
          row('Willpower', stats.willpower),
          row('Charisma', stats.charisma),
          row('Creativity', stats.creativity),
          row('Fertility', fertility, key: const Key('trait-fertility')),
        ],
      ),
    );
  }

  /// The avatar of the person the pending life event is about (a parent, a
  /// sibling, a classmate, a teacher, a coworker or a stranger). Null when the
  /// event is not about anyone: the overlay then shows its usual icon.
  Widget? _eventNpcAvatar(LifeEventDefinition event) {
    final pending = engine.state.lifeProgress.pending;

    if (pending == null) return null;

    final year = engine.state.clock.currentYear;
    final person = pending.subjectPerson;

    if (person != null) {
      return NpcAvatar(
        character: SchoolAppearance.characterFor(person),
        currentYear: year,
        size: 112,
      );
    }

    final household = engine.state.familyHousehold;
    final npcId = pending.subjectNpcId;

    if (household == null || npcId == null) return null;

    for (final parent in household.parents) {
      if (parent.id == npcId) {
        return PersonAvatar(
          id: parent.id,
          firstName: parent.firstName,
          lastName: parent.lastName,
          gender: parent.gender,
          birthYear: parent.birthYear,
          appearance: parent.appearance,
          currentYear: parent.isAlive ? year : (parent.deathYear ?? year),
        );
      }
    }

    for (final sibling in household.siblings) {
      if (sibling.id == npcId) {
        return PersonAvatar(
          id: sibling.id,
          firstName: sibling.firstName,
          lastName: sibling.lastName,
          gender: sibling.gender,
          birthYear: sibling.birthYear,
          appearance: sibling.appearance,
          currentYear: year,
        );
      }
    }

    return null;
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    double zoom,
  ) {
    final age = engine.state.player.ageAt(engine.state.clock.currentYear);

    final stage = engine.state.player.lifeStageAt(engine.state.clock.currentYear);

    // Infant and toddler show the player's info, then school, then work.
    final firstItem = stage == LifeStage.infant
        ? const _NavSlot(label: 'Infant', icon: Icons.child_care_rounded)
        : stage == LifeStage.toddler
            ? const _NavSlot(label: 'Toddler', icon: Icons.stroller_rounded)
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

/// The frame of the character header: a surface with a thick green edge on
/// the left and thin green lines on top and bottom.
class _HeaderFrame extends StatelessWidget {
  const _HeaderFrame({required this.child, required this.zoom});

  final Widget child;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      padding: EdgeInsets.fromLTRB(zoom * 8, zoom * 5, zoom * 6, zoom * 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withValues(alpha: 0.12), surface],
        ),
        border: Border(
          left: BorderSide(color: primary, width: zoom * 6),
          top: BorderSide(color: primary.withValues(alpha: 0.6)),
          bottom: BorderSide(color: primary.withValues(alpha: 0.6)),
        ),
      ),
      child: child,
    );
  }
}

/// A small rounded plate behind the avatar.
class _AvatarPlate extends StatelessWidget {
  const _AvatarPlate({required this.child, required this.zoom});

  final Widget child;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(zoom * 2),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(zoom * 10),
        border: Border.all(color: primary, width: 1.5),
      ),
      child: child,
    );
  }
}

/// The player's money as a green pill.
class _MoneyPill extends StatelessWidget {
  const _MoneyPill({required this.child, required this.zoom});

  final Widget child;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: zoom * 8, vertical: zoom * 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(zoom * 12),
      ),
      child: child,
    );
  }
}

/// A small tag in the header: outlined, or filled green when [filled].
class _HeaderTag extends StatelessWidget {
  const _HeaderTag({
    required this.child,
    required this.zoom,
    this.filled = false,
  });

  final Widget child;
  final double zoom;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textStyle = theme.textTheme.labelSmall!.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: filled ? theme.colorScheme.onPrimary : null,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: zoom * 6, vertical: zoom * 1.5),
      decoration: BoxDecoration(
        color: filled ? primary : primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(zoom * 5),
        border: Border.all(color: primary.withValues(alpha: 0.7)),
      ),
      child: DefaultTextStyle.merge(
        style: textStyle,
        maxLines: 1,
        softWrap: false,
        child: child,
      ),
    );
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
      height: s(_GameScreenState._navigationHeight + _GameScreenState._ageUpRise),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The bar, with a green line above and below it.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: s(_GameScreenState._navigationHeight),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    item(
                      icon: firstSlot.icon,
                      label: firstSlot.label,
                      onTap: onCareerTap,
                    ),
                    item(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Assets',
                      onTap: onAssetsTap,
                    ),
                    SizedBox(width: s(72)),
                    item(
                      icon: Icons.family_restroom_rounded,
                      label: 'Life',
                      onTap: onLifeTap,
                    ),
                    item(
                      icon: Icons.more_horiz_rounded,
                      label: 'More',
                      onTap: onMoreTap,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Age Up sits in the middle of the bar and rises above it.
          Positioned(
            left: 0,
            right: 0,
            bottom: s(3),
            child: Center(
              child: _AgeUpButton(
                zoom: zoom,
                enabled: !isProcessing,
                onTap: onAgeUpTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeUpButton extends StatefulWidget {
  const _AgeUpButton({
    required this.zoom,
    required this.enabled,
    required this.onTap,
  });

  final double zoom;
  final bool enabled;
  final Future<void> Function() onTap;

  @override
  State<_AgeUpButton> createState() => _AgeUpButtonState();
}

class _AgeUpButtonState extends State<_AgeUpButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // The button pops, its ring spins, and a wave spreads from it.
    _controller.forward(from: 0);
    await widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * widget.zoom;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final pop = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.88), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.08), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 45),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    return Material(
      key: const Key('bottom-nav-age-up'),
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final spin = Curves.easeOutCubic.transform(t) * 2 * math.pi;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // The wave: a green ring that grows and fades out.
              if (_controller.isAnimating)
                IgnorePointer(
                  child: Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 1 + t * 0.55,
                      child: Container(
                        width: s(80),
                        height: s(80),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primary, width: 3),
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.scale(
                scale: pop.value,
                child: Transform.rotate(angle: spin, child: child),
              ),
            ],
          );
        },
        child: InkWell(
          onTap: widget.enabled ? _handleTap : null,
          customBorder: const CircleBorder(),
          child: Opacity(
            // No dimming while a year is processing: that made the bar flicker.
            opacity: 1.0,
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
                  color: primary,
                  background: theme.colorScheme.surface,
                ),
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

/// One bottom tab: a white icon on a green key-shaped tile.
class _NavigationItem extends StatefulWidget {
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
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  /// The tile squeezes, then pops out and settles.
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82), weight: 25),
    TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.14), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.14, end: 1.0), weight: 35),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * widget.zoom;

    final theme = Theme.of(context);

    return InkWell(
      onTap: widget.enabled ? _handleTap : null,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: s(2),
          vertical: s(2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: s(38),
                height: s(34),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(s(11)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.alphaBlend(
                        Colors.black.withValues(alpha: 0.35),
                        theme.colorScheme.primary,
                      ),
                      offset: Offset(0, s(3)),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: s(22),
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: s(2)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.label,
                maxLines: 1,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
