
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:narad/models/user.dart';
import 'package:narad/utils/functions.dart';
import 'package:narad/view/friends/widgets/friends_profile.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/avatar_icon.dart';
import 'package:narad/view/widgets/friend_popup_menu.dart';
import 'package:narad/view/widgets/popup_menu.dart';
import 'package:page_transition/page_transition.dart';

import 'back_icon.dart';

class MessagesHeader extends StatelessWidget {
  final MUser friend;
  const MessagesHeader({Key key, @required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);

    return Padding(
      padding: EdgeInsets.only(
        top: deviceData.screenHeight * 0.06,
        bottom: deviceData.screenHeight * 0.005,
        left: deviceData.screenWidth * 0.05,
        right: deviceData.screenWidth * 0.05,
      ),
      child:Container(
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          BackIcon(),
          InkWell(
              child: Row(
            children: [
              AvatarIcon(
                user: friend,
                radius: 0.05,
              ),
              SizedBox(width: deviceData.screenWidth * 0.035),
              Text(
                Functions.getFirstName(friend.name),
                style: kArialFontStyle.copyWith(
                  fontSize: deviceData.screenHeight * 0.022,
                  color: Colors.white,
                ),
              ),
            ],
          ),
            onTap: (){
              if (!KeyboardVisibilityController().isVisible) {
                Navigator.push(
                    context,
                    PageTransition(
                      duration: Duration(milliseconds: 100),
                        type: PageTransitionType.fade,
                        child: FriendsProfileScreen(friend: friend)));
              } else {
                FocusScope.of(context).unfocus();
              }
            },
          ),
          FriendPopUpMenu(friend: friend),
        ],
      ),)
    );
  }
}