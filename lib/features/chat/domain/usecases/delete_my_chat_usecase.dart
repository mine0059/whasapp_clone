import 'package:whatsapp_clone/features/chat/domain/entities/chat_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/repository/chat_repository.dart';

class DeleteMyChatUsecase {
  final ChatRepository repository;

  DeleteMyChatUsecase({required this.repository});

  Future<void> call(ChatEntity chat) async {
    return await repository.deleteChat(chat);
  }
}
