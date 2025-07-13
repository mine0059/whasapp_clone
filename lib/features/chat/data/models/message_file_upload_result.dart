class MessageFileUploadResult {
  final bool success;
  final String? fileId;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final Map<String, String>? urls;
  final String? cloudinaryUrl;
  final String messageId;
  final String chatId;
  final String? messageType;
  final String? error;

  MessageFileUploadResult({
    required this.success,
    this.fileId,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.urls,
    this.cloudinaryUrl,
    required this.messageId,
    required this.chatId,
    this.messageType,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'fileId': fileId,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'urls': urls,
      'cloudinaryUrl': cloudinaryUrl,
      'messageId': messageId,
      'chatId': chatId,
      'messageType': messageType,
      'error': error,
    };
  }
}
