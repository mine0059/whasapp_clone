import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
        emit(
            GetSingleUserFailure()); // or create a specific state like NoUserFound
      }
    }, onError: (e) {
      emit(GetSingleUserFailure());
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
