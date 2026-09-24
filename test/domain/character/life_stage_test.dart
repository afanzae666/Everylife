import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/life_stage.dart';

void main() {
  group('LifeStageAge.fromAge', () {
    test('maps infant ages correctly', () {
      expect(LifeStageAge.fromAge(0), LifeStage.infant);
      expect(LifeStageAge.fromAge(2), LifeStage.infant);
    });

    test('maps toddler ages correctly', () {
      expect(LifeStageAge.fromAge(3), LifeStage.toddler);
      expect(LifeStageAge.fromAge(5), LifeStage.toddler);
    });

    test('maps child ages correctly', () {
      expect(LifeStageAge.fromAge(6), LifeStage.child);
      expect(LifeStageAge.fromAge(12), LifeStage.child);
    });

    test('maps teen ages correctly', () {
      expect(LifeStageAge.fromAge(13), LifeStage.teen);
      expect(LifeStageAge.fromAge(17), LifeStage.teen);
    });

    test('maps young adult ages correctly', () {
      expect(LifeStageAge.fromAge(18), LifeStage.youngAdult);
      expect(LifeStageAge.fromAge(29), LifeStage.youngAdult);
    });

    test('maps adult ages correctly', () {
      expect(LifeStageAge.fromAge(30), LifeStage.adult);
      expect(LifeStageAge.fromAge(59), LifeStage.adult);
    });

    test('maps senior ages correctly', () {
      expect(LifeStageAge.fromAge(60), LifeStage.senior);
      expect(LifeStageAge.fromAge(100), LifeStage.senior);
    });

    test('rejects negative ages', () {
      expect(
        () => LifeStageAge.fromAge(-1),
        throwsArgumentError,
      );
    });
  });
}
