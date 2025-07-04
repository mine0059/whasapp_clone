import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/get_single_user_usecase.dart';

part 'get_single_user_state.dart';

class GetSingleUserCubit extends Cubit<GetSingleUserState> {
  final GetSingleUserUsecase getSingleUserUsecase;
  GetSingleUserCubit({required this.getSingleUserUsecase})
      : super(GetSingleUserInitial());

  Future<void> getSingleUser({required String uid}) async {
    emit(GetSingleUserLoading());
    final streamResponse = getSingleUserUsecase.call(uid);
    streamResponse.listen((users) {
      if (users.isNotEmpty) {
        emit(GetSingleUserLoaded(singleUser: users.first));
      } else {
        emit(
            GetSingleUserFailure()); // or create a specific state like NoUserFound
      }
    }, onError: (e) {
      emit(GetSingleUserFailure());
    });
  }
}
