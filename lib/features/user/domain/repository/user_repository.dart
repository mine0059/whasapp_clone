import 'dart:io';
import 'package:whatsapp_clone/features/user/domain/entities/contact_entity.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<void> verifyPhoneNumber(String phoneNumber);
  Future<void> signInWithPhoneNumber(String smsPinCode);

  Future<bool> isSignIn();
  Future<void> signOut();
  Future<String> getCurrentUID();
  Future<void> createUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Stream<List<UserEntity>> getAllUsers();
  Stream<List<UserEntity>> getSingleUser(String uid);

  Future<List<ContactEntity>> getDeviceNumber();

  // Storage methods
  Future<String> uploadProfileImage({
    required File file,
    Function(bool isUploading)? onComplete,
  });

  Future<List<String>> uploadStatuses({
    required List<File> files,
    Function(bool isUploading)? onComplete,
    String? description,
  });

  Future<String> uploadMessageFile({
    required File file,
    Function(bool isUploading)? onComplete,
    String? uid,
    String? otherUid,
    String? type,
    String? chatId,
  });
}
