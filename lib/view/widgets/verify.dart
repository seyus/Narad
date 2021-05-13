import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:narad/view/friends/widgets/friends_screen.dart';

class VerifyScreen extends StatefulWidget {
  final String email;
  VerifyScreen({@required this.email});

  @override
  VerifyScreenState createState() => VerifyScreenState();
}

class VerifyScreenState extends State<VerifyScreen>{
  final auth = FirebaseAuth.instance;
  User user;
  Timer timer;
  
  @override
  void initState() {
    user = auth.currentUser;
    
    timer = Timer.periodic(Duration(seconds: 5), (timer){
      checkEmailVerified();
    });
    
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "To Continue please verify the mail sent to you on ${widget.email}",
          textAlign: TextAlign.center,
        ),
      )
    );
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user.reload();
    if(user.emailVerified){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => FriendsScreen()),
      );
      timer.cancel();
    }
  }

}