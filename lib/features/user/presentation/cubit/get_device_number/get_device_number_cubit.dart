import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/user/domain/entities/contact_entity.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/get_device_number_usecase.dart';

part 'get_device_number_state.dart';

class GetDeviceNumberCubit extends Cubit<GetDeviceNumberState> {
  final GetDeviceNumberUsecase getDeviceNumberUsecase;
  GetDeviceNumberCubit({required this.getDeviceNumberUsecase})
      : super(GetDeviceNumberInitial());

  Future<void> getDeviceNumber() async {
    emit(GetDeviceNumberLoading());
    debugPrint("📱 Starting to fetch device contacts...");

    try {
      final startTime = DateTime.now();
      final contactNumbers = await getDeviceNumberUsecase.call();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      debugPrint(
          "✅ Fetched ${contactNumbers.length} contacts in ${duration.inMilliseconds}ms");
      emit(GetDeviceNumberLoaded(contacts: contactNumbers));
    } catch (e) {
      debugPrint("❌ Error fetching device contacts: $e");
      emit(GetDeviceNumberFailure());
    }
  }
}
