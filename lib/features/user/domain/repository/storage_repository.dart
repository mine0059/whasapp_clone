import 'dart:io';
import 'package:whatsapp_clone/features/chat/data/models/message_file_info.dart';
import 'package:whatsapp_clone/features/chat/data/models/message_file_upload_result.dart';

abstract class StorageRepository {
  Future<String> uploadProfileImage({
    required File file,
    Function(bool isUploading)? onComplete,
  });

  Future<List<String>> uploadStatuses({
    required List<File> files,
    Function(bool isUploading)? onComplete,
    String? description,
  });

  Future<MessageFileUploadResult> uploadMessageFile({
    required File file,
    required String messageId,
    required String chatId,
    String? messageType,
    Function(bool isUploading)? onComplete,
    Function(double progress)? onProgress,
  });

  Future<bool> deleteFile({
    required String fileId,
    String? messageId,
    String? chatId,
  });
  
  Future<MessageFileInfo> getFileInfo({
    required String fileId,
    String? messageId,
    String? chatId,
  });
  
  Future<List<MessageFileInfo>> getUserFiles({
    int limit = 20,
    int offset = 0,
    String? mimeType,
    String? chatId,
  });

  Future<bool> linkFileToMessage({
    required String fileId,
    required String messageId,
    required String chatId,
  });

  Future<List<MessageFileInfo>> getMessageFiles({
    required String messageId,
    String? chatId,
  });

  Future<bool> updateMessageFileStatus({
    required String messageId,
    required String status,
    required String chatId,
    String? fileId,
  });

  Future<String> uploadWithProgress({
    required File file,
    required String uploadType,
    required String category,
    Function(double progress)? onProgress,
    Function(bool isUploading)? onComplete,
    Map<String, String>? additionalFields,
  });

  Future<MessageFileUploadResult> uploadMessageFileWithProgress({
    required File file,
    required String messageId,
    required String chatId,
    String? messageType,
    Function(double progress)? onProgress,
    Function(bool isUploading)? onComplete,
  });
}