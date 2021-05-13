import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:narad/models/message.dart';
import 'package:narad/models/user.dart';
import 'package:narad/models/user_presentation.dart';

abstract class StorageRepository {
  Stream<List<UserPresentation>> fetchFirstUsers(
      {@required String userId, @required int maxLength});

  Stream<List<Message>> fetchFirstMessages(
      {@required String userId,
        @required String friendId,
        @required int maxLength});

  Future<List<Message>> fetchNextMessages({@required String userId,@required String friendId,
    @required int maxLength, @required int firstMessagesLength});

  Future<void> sendMessage(
      {@required String message,
        @required String userId,
        @required String friendId});

  Future<MUser> fetchProfileUser([String userID]);
  Future<void> saveProfileUser(MUser user);
  Future<void> markMessageSeen(String userId, String friendId);
  Future<void> currentlyListening(
      {String userId, @required String friendId, @required String song});
  Future<MUser> updateProfileNameAndImage(
      {@required String userId,
        @required String name,
        @required String bio,
        File photo,
        String imgUrl});
  Future<List<UserPresentation>> searchByName(
      {@required String userId, @required String name});
}