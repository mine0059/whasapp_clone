import 'package:whatsapp_clone/features/chat/domain/entities/message_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/repository/chat_repository.dart';

class DeleteMessageUsecase {
  final ChatRepository repository;

  DeleteMessageUsecase({required this.repository});

  Future<void> call(MessageEntity message) async {
    return await repository.deleteMessage(message);
  }
}
