import 'package:whatsapp_clone/features/user/data/data_sources/remote/user_remote_data_source.dart';
import 'package:whatsapp_clone/features/user/data/data_sources/remote/user_remote_data_source_impl.dart';
import 'package:whatsapp_clone/features/user/data/repository/user_repository_impl.dart';
import 'package:whatsapp_clone/features/user/domain/repository/user_repository.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/credential/get_current_uid_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/credential/is_sign_in_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/credential/sign_in_with_phone_number_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/credential/sign_out_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/credential/verify_phone_number_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/create_user_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/get_all_users_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/get_device_number_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/get_single_user_usecase.dart';
import 'package:whatsapp_clone/features/user/domain/usecases/user/update_user_usecase.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/auth/auth_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/credential/credential_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_device_number/get_device_number_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_single_user/get_single_user_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/user/user_cubit.dart';
import 'package:whatsapp_clone/main_injection_container.dart';

Future<void> userInjectionContainer() async {
  // * CUBITS INJECTION

  sl.registerFactory<AuthCubit>(() => AuthCubit(
        getCurrentUidUsecase: sl.call(),
        isSignInUsecase: sl.call(),
        signOutUsecase: sl.call(),
      ));

  sl.registerFactory<UserCubit>(() => UserCubit(
        getAllUsersUsecase: sl.call(),
        updateUserUsecase: sl.call(),
      ));

  sl.registerFactory<GetSingleUserCubit>(
      () => GetSingleUserCubit(getSingleUserUsecase: sl.call()));

  sl.registerFactory<CredentialCubit>(() => CredentialCubit(
      createUserUsecase: sl.call(),
      signInWithPhoneNumberUsecase: sl.call(),
      verifyPhoneNumberUsecase: sl.call()));

  sl.registerFactory<GetDeviceNumberCubit>(
      () => GetDeviceNumberCubit(getDeviceNumberUsecase: sl.call()));

  // * USE CASE INJECTION
  sl.registerLazySingleton<GetCurrentUidUsecase>(
      () => GetCurrentUidUsecase(repository: sl.call()));

  sl.registerLazySingleton<IsSignInUsecase>(
      () => IsSignInUsecase(repository: sl.call()));

  sl.registerLazySingleton<SignOutUsecase>(
      () => SignOutUsecase(repository: sl.call()));

  sl.registerLazySingleton<CreateUserUsecase>(
      () => CreateUserUsecase(repository: sl.call()));

  sl.registerLazySingleton<GetAllUsersUsecase>(
      () => GetAllUsersUsecase(repository: sl.call()));

  sl.registerLazySingleton<UpdateUserUsecase>(
      () => UpdateUserUsecase(repository: sl.call()));

  sl.registerLazySingleton<GetSingleUserUsecase>(
      () => GetSingleUserUsecase(repository: sl.call()));

  sl.registerLazySingleton<SignInWithPhoneNumberUsecase>(
      () => SignInWithPhoneNumberUsecase(repository: sl.call()));

  sl.registerLazySingleton<VerifyPhoneNumberUsecase>(
      () => VerifyPhoneNumberUsecase(repository: sl.call()));

  sl.registerLazySingleton<GetDeviceNumberUsecase>(
      () => GetDeviceNumberUsecase(repository: sl.call()));

  // * REPOSITORY & DATA SOURCES INJECTION

  sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(remoteDataSource: sl.call()));

  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(
        auth: sl.call(),
        fireStore: sl.call(),
      ));
}
