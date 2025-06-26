import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';

class GetSingleUserUsecase {
  final UserRepository repository;

  GetSingleUserUsecase({
    required this.repository,
  });

  Stream<List<UserEntity>> call(String uid) {
    return repository.getSingleUser(uid);
  }
}
