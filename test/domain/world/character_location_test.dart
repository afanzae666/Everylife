import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/domain/world/character_location.dart';

void main() {
group('CharacterLocation', () {
test('accepts a valid country and city combination', () {
const location = CharacterLocation(
countryCode: 'ID',
cityId: 'id-jakarta',
);

  expect(location.isValid, isTrue);
});

test('accepts country code regardless of input case', () {
  const location = CharacterLocation(
    countryCode: 'id',
    cityId: 'id-jakarta',
  );

  expect(location.isValid, isTrue);
});

test('rejects an unknown country', () {
  const location = CharacterLocation(
    countryCode: 'ZZ',
    cityId: 'id-jakarta',
  );

  expect(location.isValid, isFalse);
});

test('rejects an unknown city', () {
  const location = CharacterLocation(
    countryCode: 'ID',
    cityId: 'id-unknown-city',
  );

  expect(location.isValid, isFalse);
});

test('rejects a city belonging to another country', () {
  const location = CharacterLocation(
    countryCode: 'ID',
    cityId: 'us-new-york',
  );

  expect(location.isValid, isFalse);
});

test('checks whether the location belongs to a country', () {
  const location = CharacterLocation(
    countryCode: 'ID',
    cityId: 'id-jakarta',
  );

  expect(location.belongsToCountry('ID'), isTrue);
  expect(location.belongsToCountry('id'), isTrue);
  expect(location.belongsToCountry('US'), isFalse);
});

test('does not match a country for an invalid location', () {
  const location = CharacterLocation(
    countryCode: 'US',
    cityId: 'id-jakarta',
  );

  expect(location.belongsToCountry('US'), isFalse);
});

});
}
