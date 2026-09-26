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
    required this.onUiScaleChanged,
    this.uiScaleController,
    super.key,
  });

  final SimulationEngine engine;

  final Future<void> Function(double value)
      onUiScaleChanged;

  final ValueNotifier<double>? uiScaleController;

  @override
  State<GameScreen> createState() =>
      _GameScreenState();
}

class _GameScreenState
    extends State<GameScreen> {
  SimulationEngine get engine => widget.engine;

  late final ValueNotifier<double>
      _uiScaleController;

  late final bool
      _ownsUiScaleController;

  bool _isProcessingTurn = false;

  @override
  void initState() {
    super.initState();

    if (widget.uiScaleController != null) {
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
          onUiScaleChanged:
              widget.onUiScaleChanged,
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
        _formatLifeStage(
      lifeStage,
    );

    final events =
        state.events.reversed.toList();

    return ValueListenableBuilder<double>(
      valueListenable:
          _uiScaleController,
      builder:
          (context, zoom, _) {
        final mediaQuery =
            MediaQuery.of(context);

        final scaledMediaQuery =
            mediaQuery.copyWith(
          textScaler:
              TextScaler.linear(
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
    double s(double value) =>
        value * zoom;

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
            enabled:
                !_isProcessingTurn,
            onSelected:
                _handleGameDataAction,
            itemBuilder:
                (context) => [
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
                      Icons
                          .folder_open_outlined,
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    EdgeInsets.fromLTRB(
                  s(8),
                  s(4),
                  s(8),
                  s(6),
                ),
                children: [
                  _ResponsiveCard(
                    padding:
                        EdgeInsets.all(
                      s(8),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .center,
                      children: [
                        Material(
                          color:
                              Colors.transparent,
                          child: InkWell(
                            key: const Key(
                              'character-avatar',
                            ),
                            onTap:
                                _openCharacterProfile,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              s(40),
                            ),
                            child:
                                CircleAvatar(
                              radius: s(27),
                              child: Icon(
                                player.gender ==
                                        Gender
                                            .male
                                    ? Icons
                                        .person
                                    : Icons
                                        .person_outline,
                                size:
