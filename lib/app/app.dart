
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/random/seeded_random.dart';
import '../data/repositories/save_repository.dart';
import '../data/repositories/ui_settings_repository.dart';
import '../domain/character/character.dart';
import '../presentation/screens/character_creation_screen.dart';
import '../presentation/screens/game_screen.dart';
import '../presentation/screens/loading_screen.dart';
import '../simulation/engine/simulation_engine.dart';
import '../simulation/systems/event_system.dart';
import 'app_dependencies.dart';

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

  @override
  void initState() {
    super.initState();

    _saveRepository =
        widget.dependencies.createSaveRepository();

    _uiSettingsRepository =
        widget.dependencies.createUiSettingsRepository();

    _uiScaleController = ValueNotifier<double>(1.0);

    _initialize();

    unawaited(_loadUiScale());
  }

  @override
  void dispose() {
    _uiScaleController.dispose();
    super.dispose();
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

      engine.registerSystem(
        EventSystem(
          random: engine.random,
        ),
      );

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

  Future<SaveData?> _loadStartupSave() async {
    final autosave = await _saveRepository.load(
      slot: SaveSlot.autosave,
    );

    if (autosave != null) {
      return autosave;
    }

    const manualSlots = [
      SaveSlot.manual1,
      SaveSlot.manual2,
      SaveSlot.manual3,
      SaveSlot.manual4,
    ];

    SaveData? latestManualSave;

    for (final slot in manualSlots) {
      final saveData = await _saveRepository.load(
        slot: slot,
      );

      if (saveData == null) {
        continue;
      }

      if (latestManualSave == null) {
        latestManualSave = saveData;
        continue;
      }

      final currentSavedAt = saveData.savedAt;
      final latestSavedAt = latestManualSave.savedAt;

      if (currentSavedAt != null &&
          (latestSavedAt == null ||
              currentSavedAt.isAfter(latestSavedAt))) {
        latestManualSave = saveData;
      }
    }

    return latestManualSave;
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
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to save your new life. Please try again.',
            ),
          ),
        );
      }

      return;
    }

    setState(() {
      _engine = engine;
      _isCreatingCharacter = false;
    });
  }

  Future<NewLifeRequestAction?> _requestNewLife() {
    final navigatorContext = _navigatorKey.currentContext;

    if (navigatorContext == null) {
      return Future<NewLifeRequestAction?>.value(null);
    }

    return showDialog<NewLifeRequestAction>(
      context: navigatorContext,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.30),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext)
              .colorScheme
              .surface
              .withValues(alpha: 0.90),
          title: const Text('Start a New Life?'),
          content: const Text(
            'What would you like to do with your current life?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  NewLifeRequestAction.cancel,
                );
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  NewLifeRequestAction.startWithoutSaving,
                );
              },
              child: const Text('START WITHOUT SAVING'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  NewLifeRequestAction.saveCurrentLife,
                );
              },
              child: const Text('SAVE MY LIFE'),
            ),
          ],
        );
      },
    );
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
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to save your new life. Please try again.',
            ),
          ),
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
      seed: 20260924,
      saveRepository: _saveRepository,
    );

    engine.registerSystem(
      EventSystem(
        random: engine.random,
      ),
    );

    return engine;
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

    final shouldExit = await showDialog<bool>(
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
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
      ),
      useMaterial3: true,
    );

    final baseTextTheme = GoogleFonts.nunitoTextTheme(
      baseTheme.textTheme,
    );

    final everyLifeTextTheme = baseTextTheme.copyWith(
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 24.3,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 21.6,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 16.2,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 15.3,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14.4,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12.6,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 12.6,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: 11.7,
        fontWeight: FontWeight.w600,
      ),
    );

    final everyLifeTheme = baseTheme.copyWith(
      textTheme: everyLifeTextTheme,
      appBarTheme: AppBarTheme(
        titleTextStyle: everyLifeTextTheme.titleLarge?.copyWith(
          fontSize: 19.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'EveryLife',
      debugShowCheckedModeBanner: false,
      theme: everyLifeTheme,
      home: _buildHome(),
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
          child: Padding(
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
        onNewLifeRequested: _requestNewLife,
        onNewLifeCreationRequested: _startNewLifeCreation,
      ),
    );
  }
}
