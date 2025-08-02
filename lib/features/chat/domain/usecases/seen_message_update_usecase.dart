import 'package:whatsapp_clone/features/chat/domain/entities/message_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/repository/chat_repository.dart';

class SeenMessageUpdateUsecase {
  final ChatRepository repository;

  SeenMessageUpdateUsecase({required this.repository});

  Future<void> call(MessageEntity message) async {
    return await repository.seenMessageUpdate(message);
  }
}
