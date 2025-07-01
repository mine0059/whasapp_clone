import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:whatsapp_clone/features/user/domain/entities/contact_entity.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/get_device_number_usecase.dart';

part 'get_device_number_state.dart';

class GetDeviceNumberCubit extends Cubit<GetDeviceNumberState> {
  final GetDeviceNumberUsecase getDeviceNumberUsecase;
  GetDeviceNumberCubit({required this.getDeviceNumberUsecase})
      : super(GetDeviceNumberInitial());

  Future<void> getDeviceNumber() async {
    try {
      final contactNumbers = await getDeviceNumberUsecase.call();
      emit(GetDeviceNumberLoaded(contacts: contactNumbers));
    } catch (_) {
      emit(GetDeviceNumberFailure());
    }
  }
}
