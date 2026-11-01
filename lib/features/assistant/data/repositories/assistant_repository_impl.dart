import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_remote_data_source.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  AssistantRepositoryImpl(this._dataSource);
  final AssistantRemoteDataSource _dataSource;
  @override
  Future<String> reply(List<ChatMessage> conversation) => _dataSource.ask(conversation);
}
