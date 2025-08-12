import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/get_all_users_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/update_user_usecase.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UpdateUserUsecase updateUserUsecase;
  final GetAllUsersUsecase getAllUsersUsecase;
  UserCubit({required this.updateUserUsecase, required this.getAllUsersUsecase})
      : super(UserInitial());

  Future<void> getAllUsers() async {
    emit(UserLoading());
    debugPrint("🔍 UserCubit: Starting to get all users");

    try {
      final streamResponse = getAllUsersUsecase.call();
      streamResponse.listen((users) {
        debugPrint("✅ UserCubit: Successfully loaded ${users.length} users");
        emit(UserLoaded(users: users));
      }, onError: (error) {
        debugPrint("❌ UserCubit: Error loading users: $error");
        emit(UserFailure());
      });
    } catch (e) {
      debugPrint("❌ UserCubit: Exception in getAllUsers: $e");
      emit(UserFailure());
    }
  }

  Future<void> updateUser({required UserEntity user}) async {
    try {
      await updateUserUsecase.call(user);
    } catch (_) {
      emit(UserFailure());
    }
  }
}
