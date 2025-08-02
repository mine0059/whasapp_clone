import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp_clone/features/chat/domain/entities/chat_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/usecases/delete_my_chat_usecase.dart';
import 'package:whatsapp_clone/features/chat/domain/usecases/get_my_chat_usecase.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMyChatUsecase getMyChatUsecase;
  final DeleteMyChatUsecase deleteMyChatUsecase;

  ChatCubit({required this.getMyChatUsecase, required this.deleteMyChatUsecase})
      : super(ChatInitial());

  Future<void> getMyChat({required ChatEntity chat}) async {
    try {
      emit(ChatLoading());

      final streamResponse = getMyChatUsecase.call(chat);
      streamResponse.listen((chatContacts) {
        emit(ChatLoaded(chatContacts: chatContacts));
      });
    } on SocketException {
      emit(ChatFailure());
    } catch (e) {
      emit(ChatFailure());
    }
  }

  Future<void> deleteChat({required ChatEntity chat}) async {
    try {
      await deleteMyChatUsecase.call(chat);
    } on SocketException {
      emit(ChatFailure());
    } catch (e) {
      emit(ChatFailure());
    }
  }
}
