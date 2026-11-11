import '../api/api_client.dart';
import '../models/currency_rate.dart';

// Знает, КУДА обращаться за курсами, и превращает ответ в модель
class CurrencyRepository {
  final ApiClient apiClient = ApiClient();

  Future<CurrencyRate> getRates(String baseCurrency) async {
    final json = await apiClient.get(
      'https://open.er-api.com/v6/latest/$baseCurrency',
    );

    if (json['result'] != 'success') {
      throw Exception('Сервер не смог вернуть курсы');
    }

    return CurrencyRate.fromJson(json);
  }
}