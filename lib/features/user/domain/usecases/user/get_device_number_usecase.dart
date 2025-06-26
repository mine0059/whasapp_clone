import 'package:whatsapp_clone/features/user/domain/entities/contact_entity.dart';
import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';

class GetDeviceNumberUsecase {
  final UserRepository repository;
  GetDeviceNumberUsecase({
    required this.repository,
  });

  Future<List<ContactEntity>> call() async {
    return repository.getDeviceNumber();
  }
}
