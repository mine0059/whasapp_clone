import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/get_single_user_usecase.dart';

part 'get_single_user_state.dart';

class GetSingleUserCubit extends Cubit<GetSingleUserState> {
  final GetSingleUserUsecase getSingleUserUsecase;
  StreamSubscription<List<UserEntity>>? _userSubscription;

  GetSingleUserCubit({required this.getSingleUserUsecase})
      : super(GetSingleUserInitial());

  Future<void> getSingleUser({required String uid}) async {
    // Cancel any existing subscription to prevent memory leaks
    await _userSubscription?.cancel();

    emit(GetSingleUserLoading());
    final streamResponse = getSingleUserUsecase.call(uid);

    _userSubscription = streamResponse.listen((users) {
      if (users.isNotEmpty) {
        emit(GetSingleUserLoaded(singleUser: users.first));
      } else {
        // User document doesn't exist - this is normal for new users who haven't completed profile setup
        debugPrint(
            "⚠️ User document not found for UID: $uid - user may need to complete profile setup");
        emit(
            GetSingleUserFailure()); // This will show loading spinner until user completes profile
      }
    }, onError: (e) {
      debugPrint("❌ Error in getSingleUser stream: $e");
      emit(GetSingleUserFailure());
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
