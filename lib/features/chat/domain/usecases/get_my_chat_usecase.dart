import 'package:whatsapp_clone/features/chat/domain/entities/chat_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/repository/chat_repository.dart';

class GetMyChatUsecase {
  final ChatRepository repository;

  GetMyChatUsecase({required this.repository});

  Stream<List<ChatEntity>> call(ChatEntity chat) {
    return repository.getMyChats(chat);
  }
}
