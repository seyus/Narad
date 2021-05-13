import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:narad/models/user.dart';
import 'package:narad/view/friends/widgets/search_widget.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/popup_menu.dart';

import 'avatar_button.dart';
import 'back_icon.dart';

class FriendsHeader extends StatefulWidget {
  const FriendsHeader({
    Key key,
    @required this.user,
    @required this.editForm,
    @required this.onBackPressed,
    @required this.onAvatarPressed,
  }) : super(key: key);

  final MUser user;
  final bool editForm;
  final Function onBackPressed;
  final Function onAvatarPressed;

  @override
  _FriendsHeaderState createState() => _FriendsHeaderState();
}

class _FriendsHeaderState extends State<FriendsHeader> {

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Padding(
      padding: EdgeInsets.only(
        top: deviceData.screenHeight * 0.07,
        left: deviceData.screenWidth * 0.08,
        right: deviceData.screenWidth * 0.08,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(height: deviceData.screenHeight * 0.01),
              Text(
                "N  A  R  A  D",
                style: kTitleTextStyle.copyWith(
                  fontSize: deviceData.screenHeight * 0.028,
                    foreground: Paint()..shader = linearGradient
                ),
              ),
              PopUpMenu(user: widget.user,
                onPressed: () =>
              widget.onAvatarPressed != null ? widget.onAvatarPressed() : null,),
            ],
          ),
          SizedBox(height: deviceData.screenHeight * 0.02),
          Container(
            height: deviceData.screenHeight * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: widget.editForm
                      ? BackIcon(
                      onPressed: () =>
                      widget.onBackPressed != null ? widget.onBackPressed() : null)
                      : SearchWidget(),
                ),
                AvatarButton(
                  onPressed: () =>
                  widget.onAvatarPressed != null ? widget.onAvatarPressed() : null,
                ),
              ],
            ),
          ),
          SizedBox(height: deviceData.screenHeight * 0.015),
        ],
      ),
    );
  }
}