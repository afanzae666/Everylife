import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The entrance used by every overlay in the game: a soft blur behind it, and
/// the card fades and pops in.
Widget animatedDialogTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
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
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
        child: child,
      ),
    ),
  );
}

/// Like [showDialog], but with the game's overlay animation.
Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'Close',
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 260),
    transitionBuilder: animatedDialogTransition,
    pageBuilder: (dialogContext, _, __) {
      return SafeArea(child: builder(dialogContext));
    },
  );
}
