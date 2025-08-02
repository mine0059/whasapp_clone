import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/credential/sign_in_with_phone_number_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/credential/verify_phone_number_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/create_user_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/upload_profile_image_usecase.dart';

part 'credential_state.dart';

class CredentialCubit extends Cubit<CredentialState> {
  final SignInWithPhoneNumberUsecase signInWithPhoneNumberUsecase;
  final VerifyPhoneNumberUsecase verifyPhoneNumberUsecase;
  final CreateUserUsecase createUserUsecase;
  final UploadProfileImageUsecase uploadProfileImageUsecase;

  CredentialCubit({
    required this.signInWithPhoneNumberUsecase,
    required this.verifyPhoneNumberUsecase,
    required this.createUserUsecase,
    required this.uploadProfileImageUsecase,
  }) : super(CredentialInitial());

  Future<void> submitVerifyPhoneNumber({
    required String phoneNumber,
  }) async {
    try {
      await verifyPhoneNumberUsecase.call(phoneNumber);
      emit(CredentialPhoneAuthSmsCodeReceived());
    } on SocketException catch (_) {
      emit(CredentialFailure());
    } catch (_) {
      emit(CredentialFailure());
    }
  }

  Future<void> submitSmsCode({required String smsCode}) async {
    try {
      await signInWithPhoneNumberUsecase.call(smsCode);
      emit(CredentialPhoneAuthProfileInfo());
    } on SocketException catch (_) {
      emit(CredentialFailure());
    } catch (_) {
      emit(CredentialFailure());
    }
  }

  Future<void> submitProfileInfo({required UserEntity user}) async {
    try {
      debugPrint("🔧 Submitting profile info for user: ${user.username}");
      await createUserUsecase.call(user);
      debugPrint("✅ Profile info submitted successfully");
      emit(CredentialSuccess());
    } on SocketException catch (_) {
      debugPrint("❌ Network error while submitting profile");
      emit(CredentialFailure());
    } catch (e) {
      debugPrint("❌ Error submitting profile: $e");
      emit(CredentialFailure());
    }
  }

  Future<String> uploadProfileImage({
    required File file,
    Function(bool isUploading)? onComplete,
  }) async {
    try {
      return await uploadProfileImageUsecase.call(
        file: file,
        onComplete: onComplete,
      );
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
