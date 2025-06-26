import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';

class IsSignInUsecase {
  final UserRepository repository;

  IsSignInUsecase({
    required this.repository,
  });

  Future<bool> call() async {
    return repository.isSignIn();
  }
}
