import 'package:whatsapp_clone/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:whatsapp_clone/features/chat/domain/entities/chat_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/entities/message_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> deleteChat(ChatEntity chat) async =>
      remoteDataSource.deleteChat(chat);

  @override
  Future<void> deleteMessage(MessageEntity message) async =>
      remoteDataSource.deleteMessage(message);

  @override
  Stream<List<MessageEntity>> getMessages(MessageEntity message) =>
      remoteDataSource.getMessages(message);

  @override
  Stream<List<ChatEntity>> getMyChats(ChatEntity chat) =>
      remoteDataSource.getMyChat(chat);

  @override
  Future<void> seenMessageUpdate(MessageEntity message) async =>
      remoteDataSource.seenMessageUpdate(message);

  @override
  Future<void> sendMessage(ChatEntity chat, MessageEntity message) async =>
      remoteDataSource.sendMessage(chat, message);
}
