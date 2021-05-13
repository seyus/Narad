import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:narad/models/user.dart';

abstract class AuthenticationRepository {
  // final StorageRepository storageRepository = serviceLocator<StorageRepository>();
  Future<String> signIn({@required String email, @required String password});
  Future<MUser> signUp({
    @required String username,
    @required String email,
    @required String password,
  });
  Future<void> logout();
  Future<String> isSignIn();
  Future<String> getUserID();
}