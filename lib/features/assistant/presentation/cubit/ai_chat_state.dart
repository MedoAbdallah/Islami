import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

class AiChatState extends Equatable {
  const AiChatState({this.messages = const [], this.isLoading = false});
  final List<ChatMessage> messages;
  final bool isLoading;
  bool get isEmpty => messages.isEmpty;
  @override
  List<Object> get props => [messages, isLoading];
}
