/// Which currency the game shows for a country.
///
/// The game only displays three currencies: US dollar, euro and pound
/// sterling. Eurozone countries show euros, the United Kingdom shows pounds,
/// and every other country shows dollars. Prices still follow each country's
/// cost of living (that scaling happens before display), so a cheap country
/// simply shows smaller dollar amounts.
class GameCurrency {
  GameCurrency._();

  static const String usd = 'USD';
  static const String eur = 'EUR';
  static const String gbp = 'GBP';

  /// Currencies the game can display.
  static const Set<String> supported = {usd, eur, gbp};

  /// Maps a country's own currency code to the displayed currency code.
  static String forCountryCurrency(String? countryCurrencyCode) {
    final code = (countryCurrencyCode ?? '').toUpperCase();
    return supported.contains(code) ? code : usd;
  }
}
