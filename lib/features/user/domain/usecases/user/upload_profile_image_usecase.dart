import 'dart:io';
import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';

class UploadProfileImageUsecase {
  final UserRepository repository;

  UploadProfileImageUsecase({required this.repository});

  Future<String> call({
    required File file,
    Function(bool isUploading)? onComplete,
  }) async {
    return await repository.uploadProfileImage(
      file: file,
      onComplete: onComplete,
    );
  }
}