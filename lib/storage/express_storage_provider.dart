import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/chat/data/models/message_file_info.dart';
import 'package:whatsapp_clone/features/chat/data/models/message_file_upload_result.dart';

class ExpressStorageProvider {
  static const String _baseUrl =
      'http://10.0.2.2:3000/api'; // Android emulator'
  // static const String _baseUrl = 'http://192.168.1.100:3000/api'; // Physical device

  static Future<String> _getAuthToken() async {
    debugPrint('🔐 Starting authentication check...');

    // Check if Firebase Auth is initialized
    try {
      final auth = FirebaseAuth.instance;
      debugPrint('✅ Firebase Auth instance obtained');

      final user = auth.currentUser;
      debugPrint('👤 Current user: ${user?.uid ?? 'null'}');
      debugPrint('📧 User email: ${user?.email ?? 'null'}');
      debugPrint('✅ User verified: ${user?.emailVerified ?? false}');

      if (user == null) {
        debugPrint('❌ No user is currently signed in');
        throw Exception('No user is currently signed in. Please login first.');
      }

      // Check if user is properly authenticated
      debugPrint('🔄 Attempting to get ID token...');
      final idToken = await user.getIdToken(true); // Force refresh

      if (idToken == null || idToken.isEmpty) {
        debugPrint('❌ ID token is null or empty');
        throw Exception('Failed to retrieve authentication token');
      }

      debugPrint('✅ ID token retrieved successfully');
      debugPrint('🎫 Token length: ${idToken.length}');
      debugPrint('🎫 Token preview: ${idToken.substring(0, 50)}...');

      return idToken;
    } catch (e) {
      debugPrint('❌ Authentication error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');

      // Try to get more specific error info
      if (e is FirebaseAuthException) {
        debugPrint('❌ Firebase Auth Error Code: ${e.code}');
        debugPrint('❌ Firebase Auth Error Message: ${e.message}');
      }

      throw Exception('Authentication failed: $e');
    }
  }

  /// Create HTTP headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    debugPrint('Header Token::: ${token}');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  /// Enhanced file upload with proper MIME type detection
  static Future<http.MultipartFile> _createMultipartFile(
      File file, String fieldName) async {
    // Get file stats
    final fileName = path.basename(file.path);
    final fileLength = await file.length();

    // Detect MIME type from file extension
    String? mimeType = lookupMimeType(file.path);
    // Fallback MIME type detection
    if (mimeType == null) {
      final extension = path.extension(file.path).toLowerCase();
      switch (extension) {
        case '.jpg':
        case '.jpeg':
          mimeType = 'image/jpeg';
          break;
        case '.png':
          mimeType = 'image/png';
          break;
        case '.gif':
          mimeType = 'image/gif';
          break;
        case '.mp4':
          mimeType = 'video/mp4';
          break;
        case '.pdf':
          mimeType = 'application/pdf';
          break;
        default:
          mimeType = 'application/octet-stream';
      }
    }

    debugPrint('📁 File details:');
    debugPrint('  Name: $fileName');
    debugPrint('  Size: ${fileLength} bytes');
    debugPrint('  MIME Type: $mimeType');
    debugPrint('  Extension: ${path.extension(file.path)}');

    // Create the multipart file with proper content type
    return http.MultipartFile(
      fieldName,
      file.readAsBytes().asStream(),
      fileLength,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    );
  }

  /// Upload Profile Image
  /// Replaces Firebase Storage profile image upload
  static Future<String> uploadProfileImage({
    required File file,
    Function(bool isUploading)? onComplete,
  }) async {
    debugPrint('🚀 Starting profile image upload...');
    onComplete?.call(true);

    try {
      // Validate file first
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      debugPrint('📤 File validation passed, size: $fileSize bytes');

      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/files/upload'),
      );

      // Add headers
      request.headers.addAll(headers);

      // Add form fields for upload context
      request.fields.addAll({
        'uploadType': 'profile',
        'category': 'profile_picture',
        'visibility': 'public',
      });

      debugPrint('📋 Form fields added: ${request.fields}');

      // Add file with proper MIME type
      final multipartFile = await _createMultipartFile(file, 'file');
      request.files.add(multipartFile);

      debugPrint('📁 File added to request');

      // send request
      debugPrint('🚀 Sending request to: ${request.url}');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: $responseBody');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        onComplete?.call(false);

        // Return the preview URL or main URL
        final imageUrl =
            data['data']['urls']['preview'] ?? data['data']['cloudinaryUrl'];
        return imageUrl;
      } else {
        final errorData = json.decode(responseBody);
        throw Exception(
            'Upload failed (${response.statusCode}): ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Profile image upload failed: $e');
      onComplete?.call(false);
      throw Exception('Profile image upload failed: $e');
    }
  }

  /// Upload Status Images/Videos
  /// Replaces Firebase Storage status uploads
  static Future<List<String>> uploadStatuses({
    required List<File> files,
    Function(bool isUploading)? onComplete,
    String? description,
  }) async {
    debugPrint('🚀 Starting status upload for ${files.length} files...');
    onComplete?.call(true);

    try {
      List<String> uploadedUrls = [];

      for (int i = 0; i < files.length; i++) {
        debugPrint('📤 Uploading file ${i + 1}/${files.length}');

        final file = files[i];

        // Validate file
        if (!await file.exists()) {
          debugPrint('❌ File ${i + 1} does not exist, skipping...');
          continue;
        }

        final headers = await _getHeaders();
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/files/upload'),
        );

        // Add headers
        request.headers.addAll(headers);

        // Add form field for status upload
        request.fields.addAll({
          'uploadType': 'status',
          'category': 'status_media',
          'visibility': 'contacts_only',
          'description': description ?? '',
        });

        // Add file with proper MIME type
        final multipartFile = await _createMultipartFile(file, 'file');
        request.files.add(multipartFile);

        // send request
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final data = json.decode(responseBody);
          uploadedUrls.add(data['data']['cloudinaryUrl']);
          debugPrint('✅ File ${i + 1} uploaded successfully');
        } else {
          final errorData = json.decode(responseBody);
          throw Exception(
              'Status upload failed (${response.statusCode}): ${errorData['message'] ?? 'Unknown error'}');
        }
      }

      onComplete?.call(false);
      debugPrint('✅ All status files uploaded successfully');
      return uploadedUrls;
    } catch (e) {
      debugPrint('❌ Status upload failed: $e');
      onComplete?.call(false);
      throw Exception('Status upload failed: $e');
    }
  }

  /// Upload Message File (Images, Videos, Documents, Audio)
  /// Replaces Firebase Storage message file uploads
  static Future<MessageFileUploadResult> uploadMessageFile({
    required File file,
    required String messageId, // CRITICAL: MessageId from Firebase message
    required String chatId, // CRITICAL: ChatId for real-time sync
    String? messageType, // 'image', 'video', 'document', 'audio'
    Function(bool isUploading)? onComplete,
    Function(double progress)? onProgress,
  }) async {
    debugPrint('🚀 Starting message file upload...');
    debugPrint('📋 Upload context:');
    debugPrint('  MessageId: $messageId');
    debugPrint('  ChatId: $chatId');
    debugPrint('  MessageType: $messageType');

    onComplete?.call(true);
    onProgress?.call(0.0);

    try {
      // Validate file
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      // Determine message type from file if not provided
      String finalMessageType = messageType ?? _determineMessageType(file);

      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/files/upload'),
      );

      // Add headers
      request.headers.addAll(headers);

      // Add form fields for message file upload
      request.fields.addAll({
        'uploadType': 'message',
        'category': finalMessageType,
        'chatId': chatId,
        'messageId': messageId, // Server needs this for real-time sync
        'visibility': 'private',
      });

      onProgress?.call(0.3);

      // Add file with proper MIME type
      final multipartFile = await _createMultipartFile(file, 'file');
      request.files.add(multipartFile);

      onProgress?.call(0.5);

      // send request
      debugPrint('🚀 Sending file to server...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      onProgress?.call(0.9);
      debugPrint('📡 Server response status: ${response.statusCode}');
      debugPrint('📡 Server response body: $responseBody');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        onComplete?.call(false);
        onProgress?.call(1.0);
        debugPrint('✅ Message file uploaded successfully');
        debugPrint('📎 File URL: ${data['data']['cloudinaryUrl']}');

        return MessageFileUploadResult(
          success: true,
          fileId: data['data']['fileId'],
          fileName: data['data']['fileName'],
          fileSize: data['data']['fileSize'],
          mimeType: data['data']['mimeType'],
          urls: Map<String, String>.from(data['data']['urls'] ?? {}),
          cloudinaryUrl: data['data']['cloudinaryUrl'],
          messageId: messageId,
          chatId: chatId,
          messageType: finalMessageType,
        );
      } else {
        final errorData = json.decode(responseBody);
        throw Exception(
            'Message file upload failed (${response.statusCode}): ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Message file upload failed: $e');
      onComplete?.call(false);
      onProgress?.call(0.0);

      return MessageFileUploadResult(
        success: false,
        error: e.toString(),
        messageId: messageId,
        chatId: chatId,
      );
    }
  }

  /// Helper: Determine message type from file
  static String _determineMessageType(File file) {
    final mimeType = lookupMimeType(file.path);
    if (mimeType == null) return 'document';

    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType.startsWith('audio/')) return 'audio';
    return 'document';
  }

  /// Link uploaded file to a message
  /// This method is now optional since the server automatically links files
  static Future<bool> linkFileToMessage({
    required String fileId,
    required String messageId,
    required String chatId,
  }) async {
    debugPrint('🔗 Linking file to message...');
    debugPrint('  FileId: $fileId');
    debugPrint('  MessageId: $messageId');
    debugPrint('  ChatId: $chatId');

    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse('$_baseUrl/message/$messageId/attach-file'),
        headers: headers,
        body: json.encode({
          'fileId': fileId,
          'chatId': chatId,
        }),
      );

      debugPrint('📡 Link response status: ${response.statusCode}');
      debugPrint('📡 Link response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ File linked to message successfully');
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to link file to message (${response.statusCode}): ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Link file to message failed: $e');
      throw Exception('Link file to message failed: $e');
    }
  }

  /// Get file information
  /// Useful for displaying file details in messages
  static Future<MessageFileInfo> getFileInfo({
    required String fileId,
    String? messageId,
    String? chatId,
  }) async {
    debugPrint('📋 Getting file info...');
    debugPrint('  FileId: $fileId');
    try {
      final headers = await _getHeaders();

      Uri uri = Uri.parse('$_baseUrl/files/$fileId');
      if (messageId != null && chatId != null) {
        uri = uri.replace(queryParameters: {
          'messageId': messageId,
          'chatId': chatId,
        });
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MessageFileInfo.fromJson(data['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to get file info (${response.statusCode}): ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Get file info failed: $e');
      throw Exception('Get file info failed: $e');
    }
  }

  /// Delete file
  /// Removes file from both Cloudinary and Firestore
  static Future<bool> deleteFile({
    required String fileId,
    String? messageId,
    String? chatId,
  }) async {
    debugPrint('🗑️ Deleting file...');
    debugPrint('  FileId: $fileId');
    try {
      final headers = await _getHeaders();

      Uri uri = Uri.parse('$_baseUrl/files/$fileId');
      if (messageId != null && chatId != null) {
        uri = uri.replace(queryParameters: {
          'messageId': messageId,
          'chatId': chatId,
        });
      }

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        debugPrint('✅ File deleted successfully');
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to delete file (${response.statusCode}): ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Delete file failed: $e');
      throw Exception('Delete file failed: $e');
    }
  }

  /// Get user's files
  /// For gallery view or file management
  static Future<List<MessageFileInfo>> getUserFiles({
    int limit = 20,
    int offset = 0,
    String? mimeType,
    String? chatId,
  }) async {
    debugPrint('📋 Getting user files...');
    try {
      final headers = await _getHeaders();

      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (mimeType != null) 'mimeType': mimeType,
        if (chatId != null) 'chatId': chatId,
      };

      final uri = Uri.parse('$_baseUrl/files/user/files')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files = List<MessageFileInfo>.from((data['data'] as List)
            .map((fileData) => MessageFileInfo.fromJson(fileData)));

        debugPrint('✅ Retrieved ${files.length} user files');
        return files;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to get user files (${response.statusCode}): ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Get user files failed: $e');
      throw Exception('Get user files failed: $e');
    }
  }

  /// Get message files
  /// Retrieves all files attached to a specific message
  static Future<List<MessageFileInfo>> getMessageFiles({
    required String messageId,
    String? chatId,
  }) async {
    debugPrint('📋 Getting message files...');
    debugPrint('  MessageId: $messageId');
    debugPrint('  ChatId: $chatId');

    try {
      final headers = await _getHeaders();

      Uri uri = Uri.parse('$_baseUrl/message/$messageId/files');
      if (chatId != null) {
        uri = uri.replace(queryParameters: {'chatId': chatId});
      }

      final response = await http.get(uri, headers: headers);

      debugPrint('📡 Get files response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files = List<MessageFileInfo>.from((data['data'] as List)
            .map((fileData) => MessageFileInfo.fromJson(fileData)));
        debugPrint('✅ Retrieved ${files.length} message files');
        return files;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to get message files (${response.statusCode}): ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Get message files failed: $e');
      throw Exception('Get message files failed: $e');
    }
  }

  /// Update file status in message (Critical for sync)
  /// Updates delivery status (sent, delivered, read, etc.)
  static Future<bool> updateMessageFileStatus({
    required String messageId,
    required String status, // 'sent', 'delivered', 'read', 'failed'
    required String chatId,
    String? fileId,
  }) async {
    debugPrint('🔄 Updating message file status...');
    debugPrint('  MessageId: $messageId');
    debugPrint('  Status: $status');
    debugPrint('  ChatId: $chatId');

    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.patch(
        Uri.parse('$_baseUrl/message/$messageId/file-status'),
        headers: headers,
        body: json.encode({
          'status': status,
          'chatId': chatId, // Add chatId for real-time sync
          if (fileId != null) 'fileId': fileId,
        }),
      );

      debugPrint('📡 Update status response: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Message file status updated successfully');
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to update file status (${response.statusCode}): ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Update file status failed: $e');
      throw Exception('Update file status failed: $e');
    }
  }

  /// Upload with progress tracking
  /// Enhanced version with upload progress
  static Future<String> uploadWithProgress({
    required File file,
    required String uploadType,
    required String category,
    Function(double progress)? onProgress,
    Function(bool isUploading)? onComplete,
    Map<String, String>? additionalFields,
  }) async {
    onComplete?.call(true);

    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/files/upload'),
      );

      // Add headers
      request.headers.addAll(headers);

      // Add form fields
      request.fields.addAll({
        'uploadType': uploadType,
        'category': category,
        'visibility': 'private',
        ...?additionalFields,
      });

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: path.basename(file.path),
      );
      request.files.add(multipartFile);

      // Send request with progress tracking
      final streamedResponse = await request.send();

      // Track upload progress (approximate)
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        onComplete?.call(false);
        onProgress?.call(1.0);
        return data['data']['cloudinaryUrl'];
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      onComplete?.call(false);
      throw Exception('Upload with progress failed: $e');
    }
  }

  /// Upload with progress tracking and real-time sync
  static Future<MessageFileUploadResult> uploadMessageFileWithProgress({
    required File file,
    required String messageId,
    required String chatId,
    String? messageType,
    Function(double progress)? onProgress,
    Function(bool isUploading)? onComplete,
  }) async {
    debugPrint('🚀 Starting message file upload with progress...');

    return await uploadMessageFile(
      file: file,
      messageId: messageId,
      chatId: chatId,
      messageType: messageType,
      onProgress: onProgress,
      onComplete: onComplete,
    );
  }
}
