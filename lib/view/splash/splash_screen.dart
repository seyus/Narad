import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:narad/view/friends/widgets/friends_screen.dart';
import 'package:narad/view/register/widgets/register_screen.dart';

class SplashScreen extends StatefulWidget {
  static String routeID = "SPLASH_SCREEN";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  @override
  void initState() {
    super.initState();
    initializeUser();
    navigateUser();
  }

  Future initializeUser() async {
    await Firebase.initializeApp();
    final User firebaseUser = FirebaseAuth.instance.currentUser;
    await firebaseUser.reload();
    user = _auth.currentUser;
    // get User authentication status here
  }

  navigateUser() async {
    // checking whether user already loggedIn or not
    if (_auth.currentUser != null) {
      // &&  FirebaseAuth.instance.currentUser.reload() != null
      Timer(
        Duration(seconds: 3),
            () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    FriendsScreen()),
                (Route<dynamic> route) => false),
      );
    } else {
      Timer(Duration(seconds: 4),
              () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) =>
                          RegisterScreen()),
                      (Route<dynamic> route) => false));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Image.asset(
                        'assets/images/logo rev.png',
                        height: 400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}