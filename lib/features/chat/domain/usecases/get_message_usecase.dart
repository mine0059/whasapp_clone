import 'package:whatsapp_clone/features/chat/domain/entities/message_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/repository/chat_repository.dart';

class GetMessageUsecase {
  final ChatRepository repository;

  GetMessageUsecase({required this.repository});

  Stream<List<MessageEntity>> call(MessageEntity message) {
    return repository.getMessages(message);
  }
}
