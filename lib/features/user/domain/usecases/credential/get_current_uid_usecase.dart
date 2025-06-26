import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';

class GetCurrentUidUsecase {
  final UserRepository repository;

  GetCurrentUidUsecase({
    required this.repository,
  });

  Future<String> call() async {
    return repository.getCurrentUID();
  }
}
