import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';

class VerifyPhoneNumberUsecase {
  final UserRepository repository;

  VerifyPhoneNumberUsecase({
    required this.repository,
  });

  Future<void> call(String phoneNumber) async {
    return repository.verifyPhoneNumber(phoneNumber);
  }
}
