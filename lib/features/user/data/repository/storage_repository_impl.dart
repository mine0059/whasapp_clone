import 'dart:io';
import 'package:whatsapp_clone/features/user/domain/repository/storage_repository.dart';
import 'package:whatsapp_clone/storage/express_storage_provider.dart';

class StorageRepositoryImpl implements StorageRepository {
  @override
  Future<String> uploadProfileImage({
    required File file,
    Function(bool isUploading)? onComplete,
  }) async {
    return await ExpressStorageProvider.uploadProfileImage(
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
    return await ExpressStorageProvider.uploadStatuses(
      files: files,
      onComplete: onComplete,
      description: description,
    );
  }

  @override
  Future<String> uploadMessageFile({
    required File file,
    Function(bool isUploading)? onComplete,
    String? uid,
    String? otherUid,
    String? type,
    String? chatId,
  }) async {
    return await ExpressStorageProvider.uploadMessageFile(
      file: file,
      onComplete: onComplete,
      uid: uid,
      otherUid: otherUid,
      type: type,
      chatId: chatId,
    );
  }

  @override
  Future<bool> deleteFile(String fileId) async {
    return await ExpressStorageProvider.deleteFile(fileId);
  }

  @override
  Future<Map<String, dynamic>> getFileInfo(String fileId) async {
    return await ExpressStorageProvider.getFileInfo(fileId);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserFiles({
    int limit = 20,
    int offset = 0,
    String? mimeType,
    String? chatId,
  }) async {
    return await ExpressStorageProvider.getUserFiles(
      limit: limit,
      offset: offset,
      mimeType: mimeType,
      chatId: chatId,
    );
  }
}