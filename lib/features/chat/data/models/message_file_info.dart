class MessageFileInfo {
  final String fileId;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final Map<String, String> urls;
  final String cloudinaryUrl;
  final String? messageId;
  final String? chatId;
  final String? messageType;
  final String status;
  final DateTime? uploadedAt;
  final MessageStatus? messageStatus;

  MessageFileInfo({
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.urls,
    required this.cloudinaryUrl,
    this.messageId,
    this.chatId,
    this.messageType,
    required this.status,
    this.uploadedAt,
    this.messageStatus,
  });

  factory MessageFileInfo.fromJson(Map<String, dynamic> json) {
    return MessageFileInfo(
      fileId: json['fileId'] ?? json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      mimeType: json['mimeType'] ?? '',
      urls: Map<String, String>.from(json['urls'] ?? {}),
      cloudinaryUrl: json['cloudinaryUrl'] ?? '',
      messageId: json['messageId'],
      chatId: json['chatId'],
      messageType: json['messageType'],
      status: json['status'] ?? 'uploaded',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : null,
      messageStatus: json['messageStatus'] != null
          ? MessageStatus.fromJson(json['messageStatus'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'urls': urls,
      'cloudinaryUrl': cloudinaryUrl,
      'messageId': messageId,
      'chatId': chatId,
      'messageType': messageType,
      'status': status,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'messageStatus': messageStatus?.toJson(),
    };
  }
}

class MessageStatus {
  final String status;
  final String? fileStatus;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  MessageStatus({
    required this.status,
    this.fileStatus,
    this.deliveredAt,
    this.readAt,
  });

  factory MessageStatus.fromJson(Map<String, dynamic> json) {
    return MessageStatus(
      status: json['status'] ?? '',
      fileStatus: json['fileStatus'],
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'fileStatus': fileStatus,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }
}
