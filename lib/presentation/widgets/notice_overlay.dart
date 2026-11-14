import 'package:flutter/material.dart';

import 'life_event_dialogs.dart';

/// Every notice in the game is an overlay like this one, never a bar at the
/// bottom of the screen. It closes when the player taps anywhere.
///
/// [problem] is for something that did not work out (a refused action, an
/// error). Pass a [title] and an [emoji] to make the notice fit the moment.
Future<void> showNotice(
  BuildContext context,
  String text, {
  String? title,
  String? emoji,
  bool problem = false,
  Key? dialogKey,
}) {
  return showTapToCloseOverlay(
    context,
    dialogKey: dialogKey ?? const Key('notice-overlay'),
    title: title ?? (problem ? 'Not Possible' : 'Life Story'),
    emoji: emoji ?? (problem ? '🚫' : null),
    text: text,
  );
}
