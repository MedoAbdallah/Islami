import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/chat_message.dart';

class AssistantRemoteDataSource {
  static const String _url = String.fromEnvironment(
    'AI_WORKER_URL',
    defaultValue: 'https://icy-dew-f721.mohamedmedo2282004a.workers.dev',
  );

  Future<String> ask(List<ChatMessage> history) async {
    if (_url.isEmpty) return 'المساعد غير مُعدّ بعد. يرجى المحاولة لاحقًا.';
    try {
      final response = await http.post(Uri.parse(_url),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'messages': history.map((message) => message.toJson()).toList()}),
      ).timeout(const Duration(seconds: 40));
      if (response.statusCode != 200) return 'تعذر الاتصال بالمساعد (${response.statusCode})، حاول لاحقًا.';
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic> || decoded['reply'] is! String || (decoded['reply'] as String).trim().isEmpty) {
        return 'وصل رد غير صالح من المساعد. حاول مرة أخرى.';
      }
      return (decoded['reply'] as String).trim();
    } on FormatException {
      return 'وصل رد غير مفهوم من المساعد. حاول مرة أخرى.';
    } catch (_) {
      return 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى.';
    }
  }
}
