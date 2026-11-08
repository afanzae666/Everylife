import 'package:flutter/material.dart';

import '../widgets/page_top_bar.dart';
import '../widgets/themed_cards.dart';

import '../../core/money/currency_formatter.dart';
import '../../core/money/game_currency.dart';
import '../../core/result/result.dart';
import '../../data/repositories/save_repository.dart';
import '../../data/services/character_palette_service.dart';
import '../../domain/world/country_catalog.dart';
import '../widgets/character_avatar.dart';
import '../widgets/animated_dialog.dart';

/// Life Storage: every life autosaves into its own slot, and this page lists
/// them. Tapping a life asks whether to continue it.
class LifeStorageScreen extends StatefulWidget {
  const LifeStorageScreen({
    required this.zoom,
    required this.onRead,
    required this.onLoad,
    required this.onDelete,
    required this.onGameStateChanged,
    this.activeSlot,
    this.isFull = false,
    super.key,
  });

  final double zoom;

  /// The slot of the life being played right now, if it has been saved.
  final SaveSlot? activeSlot;

  final Future<SaveData?> Function(SaveSlot slot) onRead;
  final Future<Result<void>> Function(SaveSlot slot) onLoad;
  final Future<Result<void>> Function(SaveSlot slot) onDelete;
  final VoidCallback onGameStateChanged;

  /// True when the page was opened because storage is full and a new life
  /// needs room.
  final bool isFull;

  @override
  State<LifeStorageScreen> createState() => _LifeStorageScreenState();
}

class _LifeStorageScreenState extends State<LifeStorageScreen> {
  Map<SaveSlot, SaveData?> _data = {
    for (final slot in SaveSlot.values) slot: null,
  };
  Map<SaveSlot, bool> _unreadable = {};
  bool _isLoading = true;
  bool _isBusy = false;
  late final Future<CharacterPaletteService> _paletteFuture;

  double get zoom => widget.zoom;
  double s(double value) => value * zoom;

  @override
  void initState() {
    super.initState();
    _paletteFuture = CharacterPaletteService.load();
    _readAll();
  }

  Future<void> _readAll() async {
    final data = <SaveSlot, SaveData?>{};
    final unreadable = <SaveSlot, bool>{};

    for (final slot in SaveSlot.values) {
      try {
        data[slot] = await widget.onRead(slot);
      } catch (_) {
        data[slot] = null;
        unreadable[slot] = true;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _data = data;
      _unreadable = unreadable;
      _isLoading = false;
    });
  }

  Future<void> _continueLife(SaveSlot slot, SaveData data) async {
    if (_isBusy) {
      return;
    }

    if (slot == widget.activeSlot) {
      Navigator.of(context).pop(false);
      return;
    }

    final confirmed = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final player = data.state.player;
        final age = player.ageAt(data.state.clock.currentYear);

        return AlertDialog(
          key: const Key('continue-life-dialog'),
          title: const Text('Continue this life?'),
          content: Text(
            '${player.fullName}, age $age.\n'
            'Your current life stays safe in its own slot.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              key: const Key('continue-life-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('CONTINUE'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() => _isBusy = true);

    final result = await widget.onLoad(slot);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() => _isBusy = false);
      _showMessage('This life could not be loaded.');
      return;
    }

    widget.onGameStateChanged();
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteLife(SaveSlot slot, SaveData? data) async {
    if (_isBusy) {
      return;
    }

    final name = data?.state.player.fullName ?? 'this life';

    final confirmed = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          key: const Key('delete-life-dialog'),
          title: const Text('Delete this life?'),
          content: Text('$name will be gone forever.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              key: const Key('delete-life-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() => _isBusy = true);

    final result = await widget.onDelete(slot);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() => _isBusy = false);
      _showMessage('Could not delete this life.');
      return;
    }

    final data2 = await widget.onRead(slot);

    if (!mounted) {
      return;
    }

    setState(() {
      _data[slot] = data2;
      _unreadable.remove(slot);
      _isBusy = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final used = _data.values.where((data) => data != null).length +
        _unreadable.length;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              PageTopBar(title: 'Life Storage', zoom: zoom),
              Expanded(
                child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  key: const Key('life-storage-list'),
                  padding: EdgeInsets.zero,
                  children: [
                    if (widget.isFull)
                      _Banner(
                        zoom: zoom,
                        text: 'Life Storage is full. Delete a life to make '
                            'room for a new one.',
                      ),
                    Padding(
                      padding: EdgeInsets.all(s(8)),
                      child: Text(
                        '$used / ${SaveSlot.values.length} lives stored. '
                        'Every life saves automatically.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    for (final slot in SaveSlot.values)
                      _buildSlot(context, slot),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(BuildContext context, SaveSlot slot) {
    final data = _data[slot];
    final index = slot.index + 1;

    if (data == null) {
      final broken = _unreadable[slot] == true;

      return _SlotShell(
        key: Key('life-slot-${slot.name}'),
        zoom: zoom,
        child: Row(
          children: [
            SizedBox(
              width: s(56),
              height: s(56),
              child: Icon(
                broken ? Icons.error_outline : Icons.add,
                color: Theme.of(context).disabledColor,
              ),
            ),
            SizedBox(width: s(6)),
            Expanded(
              child: Text(
                broken
                    ? 'Slot $index: unreadable life'
                    : 'Slot $index: empty',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (broken)
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _deleteLife(slot, null),
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      );
    }

    final state = data.state;
    final player = state.player;
    final age = player.ageAt(state.clock.currentYear);
    final isActive = slot == widget.activeSlot;
    final ended = state.lifeProgress.ending != null;
    final country = CountryCatalog.findByCode(
      player.location?.countryCode ?? '',
    );
    final money = CurrencyFormatter.format(
      player.money,
      currencyCode: GameCurrency.forCountryCurrency(country?.currencyCode),
    );
    final theme = Theme.of(context);

    return _SlotShell(
      key: Key('life-slot-${slot.name}'),
      zoom: zoom,
      onTap: () => _continueLife(slot, data),
      child: Row(
        children: [
          _avatar(data),
          SizedBox(width: s(6)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    player.name,
                    maxLines: 1,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                SizedBox(height: s(1)),
                Text(
                  ended
                      ? 'Passed away at age $age'
                      : isActive
                          ? 'Age $age · Playing now'
                          : 'Age $age',
                  style: theme.textTheme.bodySmall,
                ),
                if (country != null)
                  Text(
                    country.name,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SizedBox(width: s(4)),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money,
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _deleteLife(slot, data),
                icon: Icon(
                  Icons.delete_outline,
                  size: s(20),
                  color: theme.colorScheme.error,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: BoxConstraints(
                  minWidth: s(32),
                  minHeight: s(32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar(SaveData data) {
    final player = data.state.player;

    return FutureBuilder<CharacterPaletteService>(
      future: _paletteFuture,
      builder: (context, snapshot) {
        final palette = snapshot.data;
        final skin = palette?.skinColor(player.appearance.skinTone);
        final eye = palette?.eyeColor(player.appearance.eyeColor);
        final hair = palette?.hairColor(player.appearance.hairColor);

        if (skin == null || eye == null || hair == null) {
          return SizedBox(width: s(56), height: s(70));
        }

        return CharacterAvatar(
          character: player,
          currentYear: data.state.clock.currentYear,
          size: s(56),
          skinColor: skin,
          eyeColor: eye,
          hairColor: hair,
        );
      },
    );
  }
}

class _SlotShell extends StatelessWidget {
  const _SlotShell({
    required this.zoom,
    required this.child,
    this.onTap,
    super.key,
  });

  final double zoom;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Cards touch each other: no gaps between slots.
    return AccentCard(
      zoom: zoom,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(3 * zoom),
          child: child,
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.zoom, required this.text});

  final double zoom;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('life-storage-full-banner'),
      width: double.infinity,
      color: theme.colorScheme.errorContainer,
      padding: EdgeInsets.all(8 * zoom),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium!.copyWith(
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}
