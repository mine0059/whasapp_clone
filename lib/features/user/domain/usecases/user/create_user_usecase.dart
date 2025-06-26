import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';

class CreateUserUsecase {
  final UserRepository repository;

  CreateUserUsecase({required this.repository});

  Future<void> call(UserEntity user) async {
    return repository.createUser(user);
  }
}
