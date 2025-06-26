import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';

class SignOutUsecase {
  final UserRepository repository;

  SignOutUsecase({
    required this.repository,
  });

  Future<void> call() async {
    return repository.signOut();
  }
}
