import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';

class SignInWithPhoneNumberUsecase {
  final UserRepository repository;

  SignInWithPhoneNumberUsecase({
    required this.repository,
  });

  Future<void> call(String smsPinCode) async {
    return repository.signInWithPhoneNumber(smsPinCode);
  }
}
