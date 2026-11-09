import '../../core/money/currency_formatter.dart';
import '../../core/money/game_currency.dart';
import '../../core/money/money.dart';
import '../../domain/world/country_catalog.dart';
import '../../domain/world/world_state.dart';

/// Money written for the life log, in the player's own currency.
abstract final class MoneyText {
  static String of(WorldState state, int minorUnits) {
    final countryCode = state.player.location?.countryCode ?? '';
    final code = GameCurrency.forCountryCurrency(
      CountryCatalog.findByCode(countryCode)?.currencyCode,
    );

    return CurrencyFormatter.format(
      Money.fromMinorUnits(minorUnits),
      currencyCode: code,
    );
  }
}
