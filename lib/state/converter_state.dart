import 'package:flutter/foundation.dart';

import '../repository/currency_repository.dart';

// Хранит все данные экрана и логику конвертации.
// ChangeNotifier нужен, чтобы после notifyListeners() экран перерисовался.
class ConverterState extends ChangeNotifier {
  final repository = CurrencyRepository();

  final currencies = ['USD', 'EUR', 'RUB', 'GBP', 'CNY', 'JPY', 'KZT', 'BYN', 'TRY'];

  String from = 'EUR';
  String to = 'RUB';

  bool isLoading = false;
  String? errorMessage; // null - ошибки нет

  // результат последней конвертации (null - ещё не считали)
  double? amount;
  double? result;
  double? rate;
  DateTime? updated;

  // дополнительное задание: история конвертаций
  List<String> history = [];

  void setFrom(String value) {
    from = value;
    notifyListeners();
  }

  void setTo(String value) {
    to = value;
    notifyListeners();
  }

  void swap() {
    final temp = from;
    from = to;
    to = temp;
    notifyListeners();
  }

  void clearHistory() {
    history = [];
    notifyListeners();
  }

  Future<void> convert(String text) async {
    errorMessage = null;
    result = null;

    // 1. Проверяем ввод пользователя
    text = text.trim().replaceAll(',', '.');

    if (text.isEmpty) {
      errorMessage = 'Введите сумму';
      notifyListeners();
      return;
    }

    final value = double.tryParse(text);

    if (value == null) {
      errorMessage = 'Сумма должна быть числом';
      notifyListeners();
      return;
    }

    if (value < 0) {
      errorMessage = 'Сумма не может быть отрицательной';
      notifyListeners();
      return;
    }

    // 2. Показываем индикатор загрузки
    isLoading = true;
    notifyListeners();

    // 3. Загружаем курс и считаем результат
    try {
      final data = await repository.getRates(from);
      final currentRate = data.rates[to];

      if (currentRate == null) {
        throw Exception('Нет курса для валюты $to');
      }

      amount = value;
      rate = currentRate;
      result = value * currentRate;
      updated = data.updated;

      history.insert(
        0,
        '${value.toStringAsFixed(2)} $from → ${result!.toStringAsFixed(2)} $to',
      );
    } catch (e) {
      // у Exception в тексте есть приставка "Exception: ", убираем её
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    // 4. Прячем индикатор и обновляем экран
    isLoading = false;
    notifyListeners();
  }
}