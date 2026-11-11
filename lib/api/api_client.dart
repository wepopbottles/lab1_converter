import 'dart:convert';

import 'package:http/http.dart' as http;

// Отвечает только за одно: отправить GET-запрос и вернуть JSON
class ApiClient {
  Future<Map<String, dynamic>> get(String url) async {
    http.Response response;

    try {
      response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
    } catch (e) {
      // сюда попадаем, если нет интернета или сервер слишком долго молчит
      throw Exception('Нет подключения к интернету');
    }

    // 200 - это "всё хорошо", любой другой код - ошибка сервера
    if (response.statusCode != 200) {
      throw Exception('Ошибка сервера: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }
}