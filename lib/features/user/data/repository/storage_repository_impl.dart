import 'dart:io';
import 'package:whatsapp_clone/features/user/domain/repository/storage_repository.dart';
import 'package:whatsapp_clone/features/chat/data/models/message_file_info.dart';
import 'package:whatsapp_clone/features/chat/data/models/message_file_upload_result.dart';
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

  @override
  Future<bool> deleteFile({
    required String fileId,
    String? messageId,
    String? chatId,
  }) async {
    return await ExpressStorageProvider.deleteFile(
      fileId: fileId,
      messageId: messageId,
      chatId: chatId,
    );
  }

  @override
  Future<MessageFileInfo> getFileInfo({
    required String fileId,
    String? messageId,
    String? chatId,
  }) async {
    return await ExpressStorageProvider.getFileInfo(
      fileId: fileId,
      messageId: messageId,
      chatId: chatId,
    );
  }

  @override
  Future<List<MessageFileInfo>> getUserFiles({
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

  @override
  Future<bool> linkFileToMessage({
    required String fileId,
    required String messageId,
    required String chatId,
  }) async {
    return await ExpressStorageProvider.linkFileToMessage(
      fileId: fileId,
      messageId: messageId,
      chatId: chatId,
    );
  }

  @override
  Future<List<MessageFileInfo>> getMessageFiles({
    required String messageId,
    String? chatId,
  }) async {
    return await ExpressStorageProvider.getMessageFiles(
      messageId: messageId,
      chatId: chatId,
    );
  }

  @override
  Future<bool> updateMessageFileStatus({
    required String messageId,
    required String status,
    required String chatId,
    String? fileId,
  }) async {
    return await ExpressStorageProvider.updateMessageFileStatus(
      messageId: messageId,
      status: status,
      chatId: chatId,
      fileId: fileId,
    );
  }

  @override
  Future<String> uploadWithProgress({
    required File file,
    required String uploadType,
    required String category,
    Function(double progress)? onProgress,
    Function(bool isUploading)? onComplete,
    Map<String, String>? additionalFields,
  }) async {
    return await ExpressStorageProvider.uploadWithProgress(
      file: file,
      uploadType: uploadType,
      category: category,
      onProgress: onProgress,
      onComplete: onComplete,
      additionalFields: additionalFields,
    );
  }

  @override
  Future<MessageFileUploadResult> uploadMessageFileWithProgress({
    required File file,
    required String messageId,
    required String chatId,
    String? messageType,
    Function(double progress)? onProgress,
    Function(bool isUploading)? onComplete,
  }) async {
    return await ExpressStorageProvider.uploadMessageFileWithProgress(
      file: file,
      messageId: messageId,
      chatId: chatId,
      messageType: messageType,
      onProgress: onProgress,
      onComplete: onComplete,
    );
  }
}