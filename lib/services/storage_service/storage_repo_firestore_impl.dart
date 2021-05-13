import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:narad/models/message.dart';
import 'package:narad/models/user.dart';
import 'package:narad/models/user_presentation.dart';
import 'package:narad/services/storage_service/storage_repository.dart';
import 'package:narad/utils/failure.dart';

class StorageRepoFirestoreImpl extends StorageRepository {
  // final Firestore _firestore = Firestore.instance;
  DocumentSnapshot lastMessageDoc;

  @override
  Stream<List<UserPresentation>> fetchFirstUsers(
      {@required String userId, @required int maxLength}) {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .orderBy(userId + "_" + 'lastMessageTime', descending: true)
          .limit(maxLength)
          .snapshots()
          .map((event) => event.docs.where((e) => e != null).map((e) {
        return UserPresentation.fromMap(userId, e.data());
      }
      ).toList());
    } catch (e) {
      throw UnImplementedFailure();
    }
  }

  Future<List<Message>> fetchNextMessages({String userId, String friendId,
    int maxLength, int firstMessagesLength}) async {
    try {
      if (lastMessageDoc == null) {
        var queryList = FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("contacts")
            .doc(friendId)
            .collection("messages")
            .orderBy('time', descending: true)
            .limit(firstMessagesLength);
        var documentlist = (await queryList.get()).docs;
        if (documentlist.length > 0) {
          lastMessageDoc = documentlist[documentlist.length - 1];
        }
      }
      final nextMessagesSnapshots = (await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("contacts")
          .doc(friendId)
          .collection("messages")
          .orderBy('time', descending: true)
          .startAfterDocument(lastMessageDoc)
          .limit(maxLength)
          .get())
          .docs;

      final List<Message> nextMessages = [];
      for (var m in nextMessagesSnapshots) {
        nextMessages.add(Message.fromMap(m.data()));
      }
      if (nextMessagesSnapshots.length > 0) {
        lastMessageDoc =
        nextMessagesSnapshots[nextMessagesSnapshots.length - 1];
      }
      return nextMessages;
    } catch (e) {
      throw UnImplementedFailure();
    }
  }

  @override
  Stream<List<Message>>  fetchFirstMessages({
    @required  String userId, @required  String friendId,@required int maxLength}) async* {
    try {
      yield* FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("contacts")
          .doc(friendId)
          .collection("messages")
          .orderBy('time', descending: true)
          .limit(maxLength)
          .snapshots()
          .map((event) => event.docs.where((e) {
        return e != null;
      }).map((e) {
        return Message.fromMap(e.data());
      }).toList());
    } catch (e) {
      throw UnImplementedFailure();
    }
  }

  @override
  Future<MUser> fetchProfileUser([String userId]) async {
    try {
      final userDocument =
      FirebaseFirestore.instance.collection("users").doc(userId);
      final uesrData = (await userDocument.get()).data();
      return MUser.fromMap(uesrData);
    } catch (e) {
      throw UnImplementedFailure();
    }
  }

  @override
  Future<void> saveProfileUser(MUser user) async {
    try {
      final userMap = user.toMap();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.userId)
          .set(userMap);
      final allUsersDocuments =
          (await FirebaseFirestore.instance.collection("users").get())
              .docs;
      for (var doc in allUsersDocuments) {
        if (doc.data()['userId'] != user.userId) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.userId)
              .set(
              _generateLastMessageData(
                  doc.data()['userId'], null, null, null, false),
              SetOptions(merge: true));

          await FirebaseFirestore.instance
              .collection("users")
              .doc(doc.data()['userId'])
              .set(
              _generateLastMessageData(
                  user.userId, null, null, null, false),
              SetOptions(merge: true));
        }
      }
    } catch (e) {
      throw UnImplementedFailure();
    }
  }

  Map<String, dynamic> _generateLastMessageData(
      String id, String message, String senderId, String time, bool seen) {
    final Map<String, dynamic> lastMessageData = {
      id + "_" + 'lastMessage': message,
      id + "_" + 'lastMessageSenderId': senderId,
      id + "_" + 'lastMessageTime': time,
      id + "_" + 'lastMessageSeen': seen
    };
    return lastMessageData;
  }

  @override
  Future<void> sendMessage(
      {String message, String userId, String friendId}) async {
    try {
      final timeStamp = Timestamp.now().millisecondsSinceEpoch.toString();
      final messageData =
      Message(message: message, senderId: userId, time: timeStamp).toMap();
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("contacts")
          .doc(friendId)
          .collection("messages")
          .doc(timeStamp)
          .set(messageData);
      FirebaseFirestore.instance
          .collection("users")
          .doc(friendId)
          .collection("contacts")
          .doc(userId)
          .collection("messages")
          .doc(timeStamp)
          .set(messageData);
      FirebaseFirestore.instance.collection("users").doc(userId).set(
          _generateLastMessageData(friendId, message, userId, timeStamp, false),
          SetOptions(merge: true));
      FirebaseFirestore.instance.collection("users").doc(friendId).set(
          _generateLastMessageData(userId, message, userId, timeStamp, true),
          SetOptions(merge: true));
    } catch (e) {
      throw UnImplementedFailure();
    }
  }

  @override
  Future<MUser> updateProfileNameAndImage(
      {@required String userId,
        @required String name,
        @required String bio,
        File photo,
        String imgUrl}) async {
    try {
      final userDocument =
      FirebaseFirestore.instance.collection("users").doc(userId);

      if (photo != null) {
        bool haveNetworkImage =
            (await userDocument.get()).data()['imageType'] == 'network';
        String photoUrl = await _uploadPhoto(userId, photo, haveNetworkImage);
        await userDocument.update(
            {'name': name, 'imageType': 'network', 'imgUrl': photoUrl, 'bio': bio});
      } else if (imgUrl != null) {
        await userDocument.update(
            {'name': name, 'imageType': 'assets', 'imgUrl': imgUrl, 'bio': bio});
      } else {
        await userDocument.update({'name': name, 'bio': bio});
      }
      return MUser.fromMap((await userDocument.get()).data());
    } catch (e) {
      throw UnImplementedFailure();
    }
  }

  Future<String> _uploadPhoto(String userId, File photo,
      [bool haveNetworkImage = false]) async {
    Reference storageReference =
    FirebaseStorage.instance.ref().child(userId + "_profileImage");
    if (haveNetworkImage) await storageReference.delete();
    final task = storageReference.putFile(photo);
    String photoUrl = await (await task).ref.getDownloadURL();
    return photoUrl;
  }

  @override
  Future<void> markMessageSeen(String userId, String friendId) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(friendId)
        .set({userId + "_" + 'lastMessageSeen': true}, SetOptions(merge: true));
  }

  @override
  Future<void> currentlyListening(
      {String userId, @required String friendId, @required String song}) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(friendId)
        .update({userId + "_" + 'currentlyListening': song});
  }

  @override
  Future<List<UserPresentation>> searchByName(
      {String userId, String name}) async {
    try {
      var allUsers = (await FirebaseFirestore.instance
          .collection("users")
          .orderBy(userId + "_" + 'lastMessageTime', descending: true)
          .get())
          .docs
          .map((e) => UserPresentation.fromMap(userId, e.data()))
          .toList();

      var usersStartwith = allUsers
          .where((element) =>
          element.name.toLowerCase().startsWith(name.toLowerCase()))
          .toList();

      var usersContain = allUsers
          .where((element) =>
      !element.name.toLowerCase().startsWith(name.toLowerCase()) &&
          element.name.toLowerCase().contains(name.toLowerCase()))
          .toList();

      return usersStartwith + usersContain;
    } catch (e) {
      print(e.toString());
      throw UnImplementedFailure();
    }
  }
}