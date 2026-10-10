import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../data/repositories/save_repository.dart';

class SaveLoadScreen extends StatefulWidget {
  const SaveLoadScreen({
    required this.zoom,
    required this.autoSaveController,
    required this.onRead,
    required this.onSave,
    required this.onLoad,
    required this.onDelete,
    required this.onGameStateChanged,
    this.isNewLifeFlow = false,
    super.key,
  });

  final double zoom;
  final ValueNotifier<bool> autoSaveController;

  final Future<SaveData?> Function(SaveSlot slot) onRead;

  final Future<Result<void>> Function(
    SaveSlot slot,
  ) onSave;

  final Future<Result<void>> Function(
    SaveSlot slot,
  ) onLoad;

  final Future<Result<void>> Function(
    SaveSlot slot,
  ) onDelete;

  final VoidCallback onGameStateChanged;
  final bool isNewLifeFlow;

  @override
  State<SaveLoadScreen> createState() =>
      _SaveLoadScreenState();
}

class _SaveLoadScreenState
    extends State<SaveLoadScreen> {
  static const List<SaveSlot> slots = [
    SaveSlot.autosave,
    SaveSlot.manual1,
    SaveSlot.manual2,
    SaveSlot.manual3,
    SaveSlot.manual4,
  ];

  late Map<SaveSlot, SaveData?> _saveData;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _saveData = {
      for (final slot in slots) slot: null,
    };

    _loadAllSlots();
  }

  Future<void> _loadAllSlots() async {
    final data = <SaveSlot, SaveData?>{};

    for (final slot in slots) {
      data[slot] = await widget.onRead(slot);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _saveData = data;
    });
  }

  Future<void> _refreshSlot(
    SaveSlot slot,
  ) async {
    final data = await widget.onRead(slot);

    if (!mounted) {
      return;
    }

    setState(() {
      _saveData[slot] = data;
    });
  }

  Future<void> _handleSave(
    SaveSlot slot,
  ) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final result = await widget.onSave(slot);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() {
        _isProcessing = false;
      });

      _showError('Save failed.');

      return;
    }

    await _showLifeFeedback(
      title: 'LIFE SAVED',
      message:
          'Your story has been safely preserved.',
      icon: Icons.check_circle_outline,
    );

    if (!mounted) {
      return;
    }

        Navigator.of(context).pop(
      widget.isNewLifeFlow,
    );

  Future<void> _handleOverwrite(
    SaveSlot slot,
  ) async {
    final confirmed =
        await _confirmOverwrite(slot);

    if (!mounted || !confirmed) {
      return;
    }

    await _handleSave(slot);
  }

  Future<void> _handleLoad(
    SaveSlot slot,
  ) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final result = await widget.onLoad(slot);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() {
        _isProcessing = false;
      });

      _showError('Load failed.');

      return;
    }

    widget.onGameStateChanged();

    await _showLifeFeedback(
      title: 'LIFE RESTORED',
      message: 'Your story continues.',
      icon: Icons.restore_outlined,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _handleDelete(
    SaveSlot slot,
  ) async {
    if (_isProcessing) {
      return;
    }

    final confirmed =
        await _confirmDelete(slot);

    if (!mounted || !confirmed) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final result = await widget.onDelete(slot);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() {
        _isProcessing = false;
      });

      _showError('Delete failed.');

      return;
    }

    await _refreshSlot(slot);

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<bool> _confirmOverwrite(
    SaveSlot slot,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {    

        return AlertDialog(
          title: const Text(
            'Overwrite Save?',
          ),
          content: Text(
            'Overwrite ${_slotName(slot)} '
            'with your current game?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text('OVERWRITE'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<bool> _confirmDelete(
    SaveSlot slot,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final zoom = widget.zoom;

        return AlertDialog(
          title: const Text(
            'Delete Save?',
          ),
          content: Text(
            'Delete ${_slotName(slot)} permanently?',
          ),
          actions: [
            IconButton(
              tooltip: 'Cancel',
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              icon: const Icon(
                Icons.close,
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(
                  dialogContext,
                ).colorScheme.error,
                size: 24 * zoom,
              ),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _showLifeFeedback({
    required String title,
    required String message,
    required IconData icon,
  }) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: title,
      barrierColor:
          Colors.black.withValues(alpha: 0.35),
      transitionDuration:
          const Duration(milliseconds: 240),
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return Center(
          child: _LifeFeedbackCard(
            zoom: widget.zoom,
            title: title,
            message: message,
            icon: icon,
          ),
        );
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curvedAnimation =
            CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.94,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  String _slotName(
    SaveSlot slot,
  ) {
    switch (slot) {
      case SaveSlot.autosave:
        return 'Autosave';

      case SaveSlot.manual1:
        return 'Manual 1';

      case SaveSlot.manual2:
        return 'Manual 2';

      case SaveSlot.manual3:
        return 'Manual 3';

      case SaveSlot.manual4:
        return 'Manual 4';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final scaledMediaQuery =
        mediaQuery.copyWith(
      textScaler:
          TextScaler.linear(widget.zoom),
    );

    return MediaQuery(
      data: scaledMediaQuery,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Save / Load',
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              12 * widget.zoom,
              8 * widget.zoom,
              12 * widget.zoom,
              16 * widget.zoom,
            ),
            children: [
              _buildAutoSaveCard(),
              SizedBox(
                height: 4 * widget.zoom,
              ),
              Text(
                'Manual Saves',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall,
              ),
              SizedBox(
                height: 2 * widget.zoom,
              ),
              for (final slot in slots.skip(1))
                _buildSlotCard(slot),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutoSaveCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable:
                widget.autoSaveController,
            builder: (
              context,
              enabled,
              _,
            ) {
              return SwitchListTile(
                dense: true,
                contentPadding:
                    EdgeInsets.symmetric(
                  horizontal: 16 * widget.zoom,
                ),
                secondary: Icon(
                  enabled
                      ? Icons.autorenew
                      : Icons.autorenew_outlined,
                  size: 24 * widget.zoom,
                ),
                title: const Text(
                  'Auto Save',
                ),
                subtitle: Text(
                  enabled
                      ? 'Automatically save after Age Up'
                      : 'Automatic saving is off',
                ),
                value: enabled,
                onChanged: _isProcessing
                    ? null
                    : (value) {
                        widget
                            .autoSaveController
                            .value = value;
                      },
              );
            },
          ),
          _buildSlotRow(
            SaveSlot.autosave,
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(
    SaveSlot slot,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 2 * widget.zoom,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: _buildSlotRow(slot),
      ),
    );
  }

  Widget _buildSlotRow(
    SaveSlot slot,
  ) {
    final data = _saveData[slot];

    final isAutosave =
        slot == SaveSlot.autosave;

    final isEmpty = data == null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * widget.zoom,
        vertical: 2 * widget.zoom,
      ),
      child: Row(
        children: [
          Icon(
            isAutosave
                ? Icons.autorenew
                : Icons.save_outlined,
            size: 22 * widget.zoom,
          ),
          SizedBox(
            width: 6 * widget.zoom,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _slotName(slot),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
                SizedBox(
                  height: 1 * widget.zoom,
                ),
                if (isEmpty)
                  Text(
                    'Empty',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  )
                else ...[
                  Text(
                    'Age '
                    '${data.state.player.ageAt(
                      data.state.clock.currentYear,
                    )}'
                    '  •  Year '
                    '${data.state.clock.currentYear}'
                    '  •  Money '
                    '${data.state.player.money}',
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                  Text(
                    _formatSavedAt(
                      data.savedAt,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (!isAutosave && isEmpty)
            IconButton(
              tooltip: 'Save',
              onPressed: _isProcessing
                  ? null
                  : () => _handleSave(slot),
              icon: Icon(
                Icons.save_outlined,
                size: 22 * widget.zoom,
              ),
            ),
          if (!isEmpty)
            IconButton(
              tooltip: 'Load',
              onPressed: _isProcessing
                  ? null
                  : () => _handleLoad(slot),
              icon: Icon(
                Icons.folder_open_outlined,
                size: 22 * widget.zoom,
              ),
            ),
          if (!isAutosave && !isEmpty)
            IconButton(
              tooltip: 'Overwrite',
              onPressed: _isProcessing
                  ? null
                  : () =>
                      _handleOverwrite(slot),
              icon: Icon(
                Icons.edit_note_outlined,
                size: 22 * widget.zoom,
              ),
            ),
          if (!isEmpty)
            IconButton(
              tooltip: 'Delete',
              onPressed: _isProcessing
                  ? null
                  : () =>
                      _handleDelete(slot),
              icon: Icon(
                Icons.delete_outline,
                size: 22 * widget.zoom,
              ),
            ),
        ],
      ),
    );
  }

  String _formatSavedAt(
    DateTime? value,
  ) {
    if (value == null) {
      return 'Saved —';
    }

    final local = value.toLocal();

    String two(int value) {
      return value
          .toString()
          .padLeft(2, '0');
    }

    return 'Saved '
        '${two(local.day)}/'
        '${two(local.month)}/'
        '${local.year} '
        '${two(local.hour)}:'
        '${two(local.minute)}';
  }
}

class _LifeFeedbackCard
    extends StatefulWidget {
  const _LifeFeedbackCard({
    required this.zoom,
    required this.title,
    required this.message,
    required this.icon,
  });

  final double zoom;
  final String title;
  final String message;
  final IconData icon;

  @override
  State<_LifeFeedbackCard> createState() =>
      _LifeFeedbackCardState();
}

class _LifeFeedbackCardState
    extends State<_LifeFeedbackCard> {
  @override
  void initState() {
    super.initState();

    Future<void>.delayed(
      const Duration(milliseconds: 900),
      () {
        if (!mounted) {
          return;
        }

        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 32 * widget.zoom,
        ),
        elevation: 8,
        child: Padding(
          padding: EdgeInsets.all(
            24 * widget.zoom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 46 * widget.zoom,
              ),
              SizedBox(
                height: 12 * widget.zoom,
              ),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),
              SizedBox(
                height: 6 * widget.zoom,
              ),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
