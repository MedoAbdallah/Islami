class ChatMessage {
  const ChatMessage(this.role, this.content);
  final String role;
  final String content;
  Map<String, String> toJson() => {'role': role, 'content': content};
}
