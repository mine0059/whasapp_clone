import 'dart:io';
import 'package:whatsapp_clone/features/chat/data/models/message_file_upload_result.dart';
import 'package:whatsapp_clone/features/user/data/data_sources/remote/user_remote_data_source.dart';
import 'package:whatsapp_clone/features/user/data/repository/storage_repository_impl.dart';
import 'package:whatsapp_clone/features/user/domain/entities/contact_entity.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/domain/repository/storage_repository.dart';
import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';
import 'package:whatsapp_clone/storage/express_storage_provider.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final StorageRepository storageRepository;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.storageRepository,
  });

  @override
  Future<void> createUser(UserEntity user) async =>
      remoteDataSource.createUser(user);

  @override
  Stream<List<UserEntity>> getAllUsers() => remoteDataSource.getAllUsers();

  @override
  Future<String> getCurrentUID() async => remoteDataSource.getCurrentUID();

  @override
  Future<List<ContactEntity>> getDeviceNumber() async =>
      remoteDataSource.getDeviceNumber();

  @override
  Stream<List<UserEntity>> getSingleUser(String uid) =>
      remoteDataSource.getSingleUser(uid);

  @override
  Future<bool> isSignIn() async => remoteDataSource.isSignIn();

  @override
  Future<void> signInWithPhoneNumber(String smsPinCode) async =>
      remoteDataSource.signInWithPhoneNumber(smsPinCode);

  @override
  Future<void> signOut() async => remoteDataSource.signOut();

  @override
  Future<void> updateUser(UserEntity user) async =>
      remoteDataSource.updateUser(user);

  @override
  Future<void> verifyPhoneNumber(String phoneNumber) async =>
      remoteDataSource.verifyPhoneNumber(phoneNumber);

  // Storage methods
  @override
  Future<String> uploadProfileImage({
    required File file,
    Function(bool isUploading)? onComplete,
  }) async {
    return await storageRepository.uploadProfileImage(
      file: file,
      onComplete: onComplete,
    );
  }

  @override
  Future<List<String>> uploadStatuses({
    required List<File> files,
    Function(bool isUploading)? onComplete,
    String? description,
  }) async {
    return await storageRepository.uploadStatuses(
      files: files,
      onComplete: onComplete,
      description: description,
    );
  }

  @override
  Future<MessageFileUploadResult> uploadMessageFile({
    required File file,
    required String messageId,
    required String chatId,
    String? messageType,
    Function(bool isUploading)? onComplete,
    Function(double progress)? onProgress,
  }) async {
    return await ExpressStorageProvider.uploadMessageFile(
      file: file,
      messageId: messageId,
      chatId: chatId,
      messageType: messageType,
      onComplete: onComplete,
      onProgress: onProgress,
    );
  }
}
