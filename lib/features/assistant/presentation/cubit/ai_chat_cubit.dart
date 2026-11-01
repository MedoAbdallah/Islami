import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit(this._sendMessage) : super(const AiChatState());
  final SendMessage _sendMessage;
  int _requestGeneration = 0;

  Future<void> send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || state.isLoading) return;
    final history = [...state.messages, ChatMessage('user', text)];
    final generation = ++_requestGeneration;
    emit(AiChatState(messages: history, isLoading: true));
    try {
      final reply = await _sendMessage(history);
      if (isClosed || generation != _requestGeneration) return;
      emit(AiChatState(messages: [...history, ChatMessage('assistant', reply)]));
    } catch (_) {
      if (!isClosed && generation == _requestGeneration) {
        emit(AiChatState(messages: history));
      }
    }
  }

  void clear() {
    if (state.isEmpty && !state.isLoading) return;
    _requestGeneration++;
    emit(const AiChatState());
  }
}
