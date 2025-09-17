import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/app/const/firebase_collection_const.dart';
import 'package:whatsapp_clone/features/app/const/message_type_const.dart';
import 'package:whatsapp_clone/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:whatsapp_clone/features/chat/data/models/chat_model.dart';
import 'package:whatsapp_clone/features/chat/data/models/message_model.dart';
import 'package:whatsapp_clone/features/chat/domain/entities/chat_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/entities/message_entity.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> sendMessage(ChatEntity chat, MessageEntity message) async {
    await sendMessageBasedOnType(message);

    String recentTextMessage = "";

    switch (message.messageType) {
      case MessageTypeConst.photoMessage:
        recentTextMessage = '📷 Photo';
        break;
      case MessageTypeConst.videoMessage:
        recentTextMessage = '📸 Video';
        break;
      case MessageTypeConst.audioMessage:
        recentTextMessage = '🎵 Audio';
        break;
      case MessageTypeConst.gifMessage:
        recentTextMessage = 'GIF';
        break;
      default:
        recentTextMessage = message.message!;
    }

    await addToChat(ChatEntity(
      createdAt: chat.createdAt,
      senderProfile: chat.senderProfile,
      recipientProfile: chat.recipientProfile,
      recentTextMessage: recentTextMessage,
      recipientName: chat.recipientName,
      senderName: chat.senderName,
      recipientUid: chat.recipientUid,
      senderUid: chat.senderUid,
      totalUnReadMessages: chat.totalUnReadMessages,
    ));
  }

  Future<void> addToChat(ChatEntity chat) async {
    // users -> uid -> myChat -> uid -> messages -> messageIds
    final myChatRef = firestore
        .collection(FirebaseCollectionConst.users)
        .doc(chat.senderUid)
        .collection(FirebaseCollectionConst.myChat);

    final otherChatRef = firestore
        .collection(FirebaseCollectionConst.users)
        .doc(chat.recipientUid)
        .collection(FirebaseCollectionConst.myChat);

    final myNewChat = ChatModel(
            createdAt: chat.createdAt,
            senderProfile: chat.senderProfile,
            recipientProfile: chat.recipientProfile,
            recentTextMessage: chat.recentTextMessage,
            recipientName: chat.recipientName,
            senderName: chat.senderName,
            recipientUid: chat.recipientUid,
            senderUid: chat.senderUid,
            totalUnReadMessages: chat.totalUnReadMessages)
        .toDocument();

    final otherNewChat = ChatModel(
            createdAt: chat.createdAt,
            senderProfile: chat.recipientProfile,
            recipientProfile: chat.senderProfile,
            recentTextMessage: chat.recentTextMessage,
            recipientName: chat.senderName,  // Fixed: swapped to match profile swap
            senderName: chat.recipientName,  // Fixed: swapped to match profile swap
            recipientUid: chat.senderUid,    // Fixed: swapped to match the perspective
            senderUid: chat.recipientUid,    // Fixed: swapped to match the perspective
            totalUnReadMessages: chat.totalUnReadMessages)
        .toDocument();
    try {
      myChatRef.doc(chat.recipientUid).get().then((myChatDoc) async {
        // Create
        if (!myChatDoc.exists) {
          await myChatRef.doc(chat.recipientUid).set(myNewChat);
          await otherChatRef.doc(chat.senderUid).set(otherNewChat);
          return;
        } else {
          // Update
          await myChatRef.doc(chat.recipientUid).update(myNewChat);
          await otherChatRef.doc(chat.senderUid).update(otherNewChat);
          return;
        }
      });
    } catch (e) {
      debugPrint("error occur while adding to chat");
    }
  }

  Future<void> sendMessageBasedOnType(MessageEntity message) async {
    // users -> uid -> myChat -> uid -> messages -> messageIds

    final myMessageRef = firestore
        .collection(FirebaseCollectionConst.users)
        .doc(message.senderUid)
        .collection(FirebaseCollectionConst.myChat)
        .doc(message.recipientUid)
        .collection(FirebaseCollectionConst.messages);

    final otherMessageRef = firestore
        .collection(FirebaseCollectionConst.users)
        .doc(message.recipientUid)
        .collection(FirebaseCollectionConst.myChat)
        .doc(message.senderUid)
        .collection(FirebaseCollectionConst.messages);

    String messageId = const Uuid().v1();

    final newMessage = MessageModel(
            senderUid: message.senderUid,
            recipientUid: message.recipientUid,
            senderName: message.senderName,
            recipientName: message.recipientName,
            createdAt: message.createdAt,
            repliedTo: message.repliedTo,
            repliedMessage: message.repliedMessage,
            isSeen: message.isSeen,
            messageType: message.messageType,
            message: message.message,
            messageId: messageId,
            repliedMessageType: message.repliedMessageType)
        .toDocument();

    try {
      await myMessageRef.doc(messageId).set(newMessage);
      await otherMessageRef.doc(messageId).set(newMessage);
    } catch (e) {
      debugPrint("error occur while sending message");
    }
  }

  @override
  Future<void> deleteChat(ChatEntity chat) async {
    final chatRef = firestore
        .collection(FirebaseCollectionConst.users)
        .doc(chat.senderUid)
        .collection(FirebaseCollectionConst.myChat)
        .doc(chat.recipientUid);

    try {
      await chatRef.delete();
    } catch (e) {
      print("error occur while deleting chat conversation $e");
    }
  }

  @override
  Future<void> deleteMessage(MessageEntity message) async {
    final messageRef = firestore
        .collection(FirebaseCollectionConst.users)
        .doc(message.senderUid)
        .collection(FirebaseCollectionConst.myChat)
        .doc(message.recipientUid)
        .collection(FirebaseCollectionConst.messages)
        .doc(message.messageId);

    try {
      await messageRef.delete();
    } catch (e) {
      print("error occur while deleting message $e");
    }
  }

  @override
  Stream<List<MessageEntity>> getMessages(MessageEntity message) {
    final messageRef = firestore
        .collection(FirebaseCollectionConst.users)
        .doc(message.senderUid)
        .collection(FirebaseCollectionConst.myChat)
        .doc(message.recipientUid)
        .collection(FirebaseCollectionConst.messages)
        .orderBy("createdAt", descending: false);

    return messageRef.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => MessageModel.fromSnapshot(e)).toList());
  }

  @override
  Stream<List<ChatEntity>> getMyChat(ChatEntity chat) {
    final myChatRef = firestore
        .collection(FirebaseCollectionConst.users)
        .doc(chat.senderUid)
        .collection(FirebaseCollectionConst.myChat)
        .orderBy("createdAt", descending: true);

    return myChatRef.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => ChatModel.fromSnapshot(e)).toList());
  }

  @override
  Future<void> seenMessageUpdate(MessageEntity message) async {
    final myMessagesRef = firestore
        .collection(FirebaseCollectionConst.users)
        .doc(message.senderUid)
        .collection(FirebaseCollectionConst.myChat)
        .doc(message.recipientUid)
        .collection(FirebaseCollectionConst.messages)
        .doc(message.messageId);

    final otherMessagesRef = firestore
        .collection(FirebaseCollectionConst.users)
        .doc(message.recipientUid)
        .collection(FirebaseCollectionConst.myChat)
        .doc(message.senderUid)
        .collection(FirebaseCollectionConst.messages)
        .doc(message.messageId);

    await myMessagesRef.update({"isSeen": true});
    await otherMessagesRef.update({"isSeen": true});
  }
}
