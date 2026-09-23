import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/simulation/systems/system_priority.dart';

void main() {
  test('system priorities preserve simulation order', () {
    expect(
      SystemPriority.time.value <
          SystemPriority.character.value,
      isTrue,
    );

    expect(
      SystemPriority.character.value <
          SystemPriority.event.value,
      isTrue,
    );
  });
}
