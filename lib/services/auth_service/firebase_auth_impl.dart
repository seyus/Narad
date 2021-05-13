import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:narad/models/user.dart';
import 'package:narad/utils/failure.dart';
import 'package:narad/utils/functions.dart';
import 'package:narad/view/widgets/verify.dart';

import 'auth_repository.dart';

class FirebaseAuthImpl extends AuthenticationRepository {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> signIn({String email, String password}) async {
    try {
      final authResult = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return authResult.user.uid ;
    } catch (e) {
      print("error" + e.code);
      switch (e.code) {
        case "ERROR_OPERATION_NOT_ALLOWED":
          throw UnImplementedFailure();
          break;
        case "ERROR_INVALID_EMAIL":
          throw InvalidEmailException();
          break;
        case "ERROR_WRONG_PASSWORD":
          throw WrongPasswordException();
          break;
        case "ERROR_USER_NOT_FOUND":
          throw NotFoundEmailException();
          break;
        case "ERROR_USER_DISABLED":
          throw UnImplementedFailure();
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          throw UnImplementedFailure();
          break;
        case "ERROR_NETWORK_REQUEST_FAILED":
          throw NetworkException();
          break;
        default:
          throw UnImplementedFailure();
      }
    }
  }

  @override
  Future<MUser> signUp({String username, String email, String password}) async {
    try {
      final authResult = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      String photoUrl = _generateRandomPath();
      String userbio = 'Just busy these days!';
      final user = MUser(
        userId: authResult.user.uid,
        name: username,
        email: email,
        bio: userbio,
        imageType: ImageType.assets,
        imgUrl: photoUrl,
      );
      await authResult.user.sendEmailVerification();
      //await storageRepository.saveProfileUser(user);
      return user;
    } catch (e) {
      print(e.code);
      switch (e.code) {
        case "ERROR_OPERATION_NOT_ALLOWED":
          throw UnImplementedFailure();
          break;
        case "ERROR_WEAK_PASSWORD":
          throw WeakPasswordException();
          break;
        case "ERROR_INVALID_EMAIL":
          throw InvalidEmailException();
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          throw EmailInUseException();
          break;
        case "ERROR_INVALID_CREDENTIAL":
          throw InvalidEmailException();
          break;
        case "ERROR_NETWORK_REQUEST_FAILED":
          throw NetworkException();
          break;
        default:
          throw UnImplementedFailure();
      }
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw UnImplementedFailure();
    }
  }

  @override
  Future<String> isSignIn() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        return user.uid ;
      } else {
        throw NoUserSignedInException();
      }
    } catch (e) {
      throw NoUserSignedInException();
    }
  }

  String _generateRandomPath() {
    final paths = Functions.getAvatarsPaths();

    int r = Random().nextInt(paths.length);
    while (paths[r] == Functions.femaleAvaterPath) {
      r = Random().nextInt(paths.length);
    }
    return paths[r];
  }

  @override
  Future<String> getUserID() async {
    try {
      return (firebaseAuth.currentUser).uid;
    } catch (e) {
      throw UnImplementedFailure();
    }
  }
}
