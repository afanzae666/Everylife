import 'package:everylife/core/money/game_currency.dart';
import 'package:everylife/core/money/money.dart';

import '../../core/money/currency_formatter.dart';
import '../../domain/world/country_catalog.dart';

/// An NPC's money in the currency of their country.
String npcMoneyLabel(Money amount, String countryCode) {
  final country = CountryCatalog.findByCode(countryCode);

  return CurrencyFormatter.format(
    amount,
    currencyCode: GameCurrency.forCountryCurrency(country?.currencyCode),
  );
}
