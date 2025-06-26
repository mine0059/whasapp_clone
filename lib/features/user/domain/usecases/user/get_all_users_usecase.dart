import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';

class GetAllUsersUsecase {
  final UserRepository repository;

  GetAllUsersUsecase({
    required this.repository,
  });

  Stream<List<UserEntity>> call() {
    return repository.getAllUsers();
  }
}
