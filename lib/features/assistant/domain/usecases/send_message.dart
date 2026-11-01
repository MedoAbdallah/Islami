import '../entities/chat_message.dart';
import '../repositories/assistant_repository.dart';

class SendMessage {
  const SendMessage(this._repository);
  final AssistantRepository _repository;
  Future<String> call(List<ChatMessage> history) => _repository.reply(history);
}
