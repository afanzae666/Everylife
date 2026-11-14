
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/random/seeded_random.dart';
import '../data/repositories/save_repository.dart';
import '../data/repositories/ui_settings_repository.dart';
import '../domain/character/character.dart';
import '../presentation/screens/character_creation_screen.dart';
import '../presentation/screens/game_screen.dart';
import '../presentation/screens/loading_screen.dart';
import '../simulation/engine/simulation_engine.dart';
import 'app_dependencies.dart';
import 'theme/everylife_theme.dart';
import 'theme/everylife_theme_mode_controller.dart';
import '../presentation/widgets/animated_dialog.dart';
import '../presentation/widgets/notice_overlay.dart';

class LifeSimulationApp extends StatefulWidget {
  const LifeSimulationApp({
    super.key,
    this.dependencies = const AppDependencies(),
  });

  final AppDependencies dependencies;

  @override
  State<LifeSimulationApp> createState() =>
      _LifeSimulationAppState();
}

class _LifeSimulationAppState
    extends State<LifeSimulationApp> {
  late final SaveRepository _saveRepository;

  late final UiSettingsRepository _uiSettingsRepository;

  late final ValueNotifier<double> _uiScaleController;

  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  SimulationEngine? _engine;

  bool _isInitializing = true;
  bool _isCreatingCharacter = false;
  bool _isExitDialogVisible = false;

  String? _startupError;

  /// Problems found while reading save slots during startup. A damaged slot
  /// is skipped instead of blocking the whole game.
  final List<String> _startupSaveProblems = <String>[];

  @override
  void initState() {
    super.initState();

    _saveRepository =
        widget.dependencies.createSaveRepository();

    _uiSettingsRepository =
        widget.dependencies.createUiSettingsRepository();

    _uiScaleController = ValueNotifier<double>(1.0);

    EveryLifeThemeModeController.configure(_saveThemeMode);

    _initialize();

    unawaited(_loadUiScale());
    unawaited(_loadThemeMode());
  }

  @override
  void dispose() {
    _uiScaleController.dispose();
    super.dispose();
  }

  Future<void> _loadThemeMode() async {
    try {
      final savedMode =
          await _uiSettingsRepository.loadThemeMode();

      if (!mounted) {
        return;
      }

      EveryLifeThemeModeController.setLoadedMode(
        savedMode == 'dark'
            ? ThemeMode.dark
            : ThemeMode.light,
      );
    } catch (_) {
      // Theme preferences must never prevent the game
      // from starting.
      EveryLifeThemeModeController.setLoadedMode(
        ThemeMode.light,
      );
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    await _uiSettingsRepository.saveThemeMode(
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> _loadUiScale() async {
    try {
      final uiScale =
          await _uiSettingsRepository.loadUiScale();

      if (!mounted) {
        return;
      }

      _uiScaleController.value = uiScale;
    } catch (_) {
      // UI preferences must never prevent the game
      // from starting.
    }
  }

  Future<void> _initialize() async {
    final initializationStartedAt = DateTime.now();

    try {
      final saveData = await _loadStartupSave();

      await _ensureMinimumLoadingDuration(
        initializationStartedAt,
      );

      if (!mounted) {
        return;
      }

      if (saveData == null) {
        setState(() {
          // When every existing slot was unreadable, explain it instead of
          // silently showing character creation.
          _startupError = _startupSaveProblems.isEmpty
              ? null
              : _startupSaveProblems.join('\n');
          _isInitializing = false;
        });

        return;
      }

      final engine = SimulationEngine(
        initialState: saveData.state,
        random: SeededRandom.fromState(
          saveData.randomState,
        ),
        saveRepository: _saveRepository,
        nextTickId: saveData.nextTickId,
      );

      engine.registerGameplaySystems();
      engine.activeSlot = _startupSlot;
      await engine.restoreTimeline();

      setState(() {
        _engine = engine;
        _isInitializing = false;
      });
    } catch (error) {
      await _ensureMinimumLoadingDuration(
        initializationStartedAt,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _startupError = error.toString();
        _isInitializing = false;
      });
    }
  }

  Future<void> _ensureMinimumLoadingDuration(
    DateTime startedAt,
  ) async {
    const minimumLoadingDuration = Duration(seconds: 2);

    final elapsed = DateTime.now().difference(startedAt);
    final remaining = minimumLoadingDuration - elapsed;

    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
  }

  Future<void> _saveUiScale(double value) async {
    await _uiSettingsRepository.saveUiScale(value);
  }

  /// The slot the startup save was read from.
  SaveSlot? _startupSlot;

  /// Opens the life that was played most recently. Every life lives in its
  /// own Life Storage slot, so all slots are checked.
  Future<SaveData?> _loadStartupSave() async {
    _startupSaveProblems.clear();
    _startupSlot = null;

    SaveData? latest;
    SaveSlot? latestSlot;

    for (final slot in SaveSlot.values) {
      final saveData = await _tryLoadSlot(slot);

      if (saveData == null) {
        continue;
      }

      if (latest == null) {
        latest = saveData;
        latestSlot = slot;
        continue;
      }

      final currentSavedAt = saveData.savedAt;
      final latestSavedAt = latest.savedAt;

      if (currentSavedAt != null &&
          (latestSavedAt == null ||
              currentSavedAt.isAfter(latestSavedAt))) {
        latest = saveData;
        latestSlot = slot;
      }
    }

    // A readable life is enough to start; a damaged slot stays on disk
    // untouched so it can still be inspected or recovered.
    if (latest != null) {
      _startupSaveProblems.clear();
    } else if (_startupSaveProblems.length > 1) {
      // Keep the error screen short when many slots are damaged.
      final count = _startupSaveProblems.length;
      final first = _startupSaveProblems.first;
      _startupSaveProblems
        ..clear()
        ..add('$count stored lives could not be read. First problem: $first');
    }

    _startupSlot = latestSlot;

    return latest;
  }

  Future<SaveData?> _tryLoadSlot(SaveSlot slot) async {
    try {
      return await _saveRepository.load(slot: slot);
    } catch (error) {
      _startupSaveProblems.add(
        'Save slot "${slot.name}" could not be read: $error',
      );

      return null;
    }
  }

  Future<void> _createCharacter(
    Character character,
  ) async {
    if (_isCreatingCharacter) {
      return;
    }

    setState(() {
      _isCreatingCharacter = true;
    });

    final engine = _createEngine(character);
    final saveResult = await engine.save();

    if (!mounted) {
      return;
    }

    if (!saveResult.isSuccess) {
      setState(() {
        _isCreatingCharacter = false;
      });

      final navigatorContext = _navigatorKey.currentContext;

      if (navigatorContext != null) {
        showNotice(
          navigatorContext,
          'Unable to save your new life. Please try again.',
          problem: true,
        );
      }

      return;
    }

    setState(() {
      _engine = engine;
      _isCreatingCharacter = false;
    });
  }

  void _startNewLifeCreation() {
    final navigatorContext = _navigatorKey.currentContext;

    if (navigatorContext == null) {
      return;
    }

    unawaited(
      showGeneralDialog<void>(
        context: navigatorContext,
        barrierDismissible: false,
        barrierLabel: 'Create a new life',
        barrierColor: Colors.black.withValues(alpha: 0.38),
        pageBuilder: (
          dialogContext,
          animation,
          secondaryAnimation,
        ) {
          final baseTheme = Theme.of(dialogContext);

          final overlayTheme = baseTheme.copyWith(
            scaffoldBackgroundColor: Colors.transparent,
            appBarTheme: baseTheme.appBarTheme.copyWith(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          );

          return Theme(
            data: overlayTheme,
            child: CharacterCreationScreen(
              isOverlay: true,
              uiScaleController: _uiScaleController,
              onCancel: () {
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              onCharacterCreated: (character) {
                unawaited(
                  _createNewLifeCharacter(
                    character,
                    dialogContext,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _createNewLifeCharacter(
    Character character,
    BuildContext dialogContext,
  ) async {
    if (_isCreatingCharacter) {
      return;
    }

    setState(() {
      _isCreatingCharacter = true;
    });

    final engine = _createEngine(character);
    final saveResult = await engine.save();

    if (!mounted) {
      return;
    }

    if (!saveResult.isSuccess) {
      setState(() {
        _isCreatingCharacter = false;
      });

      final navigatorContext = _navigatorKey.currentContext;

      if (navigatorContext != null) {
        showNotice(
          navigatorContext,
          'Unable to save your new life. Please try again.',
          problem: true,
        );
      }

      return;
    }

    setState(() {
      _engine = engine;
      _isCreatingCharacter = false;
    });

    if (dialogContext.mounted) {
      Navigator.of(dialogContext).pop();
    }
  }

  SimulationEngine _createEngine(Character character) {
    final engine = SimulationEngine.create(
      player: character,
      seed: DateTime.now().microsecondsSinceEpoch,
      saveRepository: _saveRepository,
    );

    engine.registerGameplaySystems();

    return engine;
  }

  /// Lets the player continue past unreadable saves. Damaged save files are
  /// not deleted; a later save simply replaces the slot it writes to.
  void _startFreshAfterStartupError() {
    setState(() {
      _startupError = null;
    });
  }

  void _retryStartup() {
    setState(() {
      _isInitializing = true;
      _startupError = null;
    });

    _initialize();
  }

  Future<void> _handleGameScreenBack() async {
    if (_isExitDialogVisible || !mounted) {
      return;
    }

    _isExitDialogVisible = true;

    final navigatorContext = _navigatorKey.currentContext;

    if (navigatorContext == null) {
      _isExitDialogVisible = false;
      return;
    }

    final shouldExit = await showAnimatedDialog<bool>(
      context: navigatorContext,
      builder: (dialogContext) {
        return AlertDialog(
          content: const Text(
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

    _isExitDialogVisible = false;

    if (shouldExit == true) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: EveryLifeThemeModeController.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'EveryLife',
          debugShowCheckedModeBanner: false,
          theme: EveryLifeTheme.light,
          darkTheme: EveryLifeTheme.dark,
          themeMode: themeMode,
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    if (_isInitializing) {
      return const LoadingScreen();
    }

    if (_startupError != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Startup Error'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load saved game.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _startupError!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _retryStartup,
                  icon: const Icon(Icons.refresh),
                  label: const Text('RETRY'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _startFreshAfterStartupError,
                  icon: const Icon(Icons.add),
                  label: const Text('START A NEW LIFE'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_engine == null) {
      return Stack(
        children: [
          CharacterCreationScreen(
            onCharacterCreated: _createCharacter,
            uiScaleController: _uiScaleController,
          ),
          if (_isCreatingCharacter)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Saving your new life...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        unawaited(_handleGameScreenBack());
      },
      child: GameScreen(
        engine: _engine!,
        uiScaleController: _uiScaleController,
        onUiScaleChanged: _saveUiScale,
        onNewLifeCreationRequested: _startNewLifeCreation,
      ),
    );
  }
}
