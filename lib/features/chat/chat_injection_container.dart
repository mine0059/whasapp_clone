import 'package:whatsapp_clone/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:whatsapp_clone/features/chat/data/data_sources/chat_remote_data_source_impl.dart';
import 'package:whatsapp_clone/features/chat/data/repository/chat_repository_impl.dart';
import 'package:whatsapp_clone/features/chat/domain/repository/chat_repository.dart';
import 'package:whatsapp_clone/features/chat/domain/usecases/delete_message_usecase.dart';
import 'package:whatsapp_clone/features/chat/domain/usecases/delete_my_chat_usecase.dart';
import 'package:whatsapp_clone/features/chat/domain/usecases/get_message_usecase.dart';
import 'package:whatsapp_clone/features/chat/domain/usecases/get_my_chat_usecase.dart';
import 'package:whatsapp_clone/features/chat/domain/usecases/seen_message_update_usecase.dart';
import 'package:whatsapp_clone/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:whatsapp_clone/features/chat/presentation/cubit/chat/chat_cubit.dart';
import 'package:whatsapp_clone/features/chat/presentation/cubit/message/message_cubit.dart';
import 'package:whatsapp_clone/main_injection_container.dart';

Future<void> chatInjectionContainer() async {
  // * CUBIT INJECTION
  sl.registerFactory<ChatCubit>(() => ChatCubit(
        getMyChatUsecase: sl.call(),
        deleteMyChatUsecase: sl.call(),
      ));

  sl.registerFactory<MessageCubit>(() => MessageCubit(
        getMessagesUseCase: sl.call(),
        sendMessageUseCase: sl.call(),
        deleteMessageUseCase: sl.call(),
        seenMessageUpdateUseCase: sl.call(),
      ));

  // * USE CASES INJECTION
  sl.registerLazySingleton<DeleteMessageUsecase>(
      () => DeleteMessageUsecase(repository: sl.call()));
  sl.registerLazySingleton<DeleteMyChatUsecase>(
      () => DeleteMyChatUsecase(repository: sl.call()));
  sl.registerLazySingleton<GetMessageUsecase>(
      () => GetMessageUsecase(repository: sl.call()));
  sl.registerLazySingleton<GetMyChatUsecase>(
      () => GetMyChatUsecase(repository: sl.call()));

  sl.registerLazySingleton<SendMessageUsecase>(
      () => SendMessageUsecase(repository: sl.call()));
  sl.registerLazySingleton<SeenMessageUpdateUsecase>(
      () => SeenMessageUpdateUsecase(repository: sl.call()));

  // * REPOSITORY AND DATASOURCE INJECTION
  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: sl.call()));

  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(firestore: sl.call()));
}
