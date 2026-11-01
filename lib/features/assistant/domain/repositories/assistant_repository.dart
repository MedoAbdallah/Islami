import '../entities/chat_message.dart';

abstract interface class AssistantRepository {
  Future<String> reply(List<ChatMessage> conversation);
}
