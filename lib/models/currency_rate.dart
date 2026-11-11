// Модель: курсы валют, которые пришли с сервера
class CurrencyRate {
  final Map<String, double> rates; // например {'RUB': 90.5, 'USD': 1.08}
  final DateTime updated; // когда сервер обновил курсы

  CurrencyRate({required this.rates, required this.updated});

  // Превращаем JSON (то, что прислал сервер) в объект
  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    final Map<String, double> rates = {};

    json['rates'].forEach((code, value) {
      rates[code] = value.toDouble();
    });

    final seconds = json['time_last_update_unix'];

    return CurrencyRate(
      rates: rates,
      updated: DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
    );
  }
}