import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  Future<String> fetchNutritionInfo(String productName) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'user',
            'content':
            'Me diga quantas calorias tem em média uma porção de "$productName". Responda de forma simples, exemplo: "140 calorias, porção: 350ml. Uma bebida gaseificada com açúcar."'
          }
        ],
        'temperature': 0.7
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      throw Exception('Falha ao consultar a IA');
    }

  }
}
