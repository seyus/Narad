
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:narad/models/user.dart';
import 'package:narad/services/cloud_messaging_service/cloud_message_repository.dart';
import 'package:narad/services/storage_service/storage_repository.dart';
import 'package:narad/utils/failure.dart';
part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final CloudMessageRepository cloudMessageRepo;
  final StorageRepository storageRepository;
  static bool isConfigured = false;

  NotificationBloc(
      {@required this.cloudMessageRepo, @required this.storageRepository})
      : super(NotificationInitial());

  @override
  Stream<NotificationState> mapEventToState(
      NotificationEvent event,
      ) async* {
    if (event is ListenToNotification) {
      try {cloudMessageRepo.configure(BuildContext);
      } on Failure catch (failure) {
        yield NotificationFailed(failure);
      }
    } else if (event is NotifcationReceivedEvent) {
      yield NotificationLoading();
      yield NotificationRecived(event.user);
    }
  }
}