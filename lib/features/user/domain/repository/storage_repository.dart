import 'dart:io';

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

  Future<String> uploadMessageFile({
    required File file,
    Function(bool isUploading)? onComplete,
    String? uid,
    String? otherUid,
    String? type,
    String? chatId,
  });

  Future<bool> deleteFile(String fileId);
  
  Future<Map<String, dynamic>> getFileInfo(String fileId);
  
  Future<List<Map<String, dynamic>>> getUserFiles({
    int limit = 20,
    int offset = 0,
    String? mimeType,
    String? chatId,
  });
}