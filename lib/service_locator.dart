import 'package:get_it/get_it.dart';
import 'package:narad/services/auth_service/auth_repository.dart';
import 'package:narad/services/auth_service/firebase_auth_impl.dart';
import 'package:narad/services/cloud_messaging_service/cloud_message_repository.dart';
import 'package:narad/services/cloud_messaging_service/cloud_messaging_impl.dart';
import 'package:narad/services/storage_service/storage_repo_firestore_impl.dart';
import 'package:narad/services/storage_service/storage_repository.dart';
import 'package:narad/view/friends/bloc/friends_bloc.dart';
import 'package:narad/view/messages/bloc/messages_bloc.dart';
import 'package:narad/view/notification/bloc/notification_bloc.dart';
import 'package:narad/view/register/bloc/account_bloc.dart';

final serviceLocator = GetIt.instance;

void serviceLoctorSetup() {
  serviceLocator.registerFactory(() => FriendsBloc(
    storageRepository: serviceLocator<StorageRepository>(),
    authService: serviceLocator<AuthenticationRepository>(),
  ));

  serviceLocator.registerFactory(() => MessagesBloc(
    storageRepository: serviceLocator<StorageRepository>(),
    authRepository: serviceLocator<AuthenticationRepository>(),
  ));

  serviceLocator.registerFactory(() => AccountBloc(
    authImpl: serviceLocator<AuthenticationRepository>(),
    storageRepository: serviceLocator<StorageRepository>(),
  ));

  serviceLocator.registerFactory(() => NotificationBloc(
    storageRepository: serviceLocator<StorageRepository>(),
    cloudMessageRepo: serviceLocator<CloudMessageRepository>(),
  ));

  serviceLocator
      .registerFactory<StorageRepository>(() => StorageRepoFirestoreImpl());

  serviceLocator
      .registerFactory<AuthenticationRepository>(() => FirebaseAuthImpl());
  serviceLocator
      .registerFactory<CloudMessageRepository>(() => CloudMessagingImpl());
}