import 'package:flutter/material.dart';
import 'package:narad/models/user.dart';
import 'package:narad/models/user_presentation.dart';
import 'package:narad/utils/functions.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/avatar_icon.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({
    Key key,
    @required this.user,
    @required this.showFriendImage,
    @required this.lastsendermsg,
    @required this.friend,
    @required this.senderId,
    @required this.message,
  }) : super(key: key);
  final UserPresentation user;
  final bool showFriendImage;
  final bool lastsendermsg;
  final UserPresentation friend;
  final String message;
  final String senderId;

  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);

    return Container(
        child: Padding(
      padding: EdgeInsets.only(
        bottom: senderId==friend.userId
            ?showFriendImage
            ?deviceData.screenHeight * 0.01
            :deviceData.screenHeight*0.001
            :lastsendermsg
            ?deviceData.screenHeight * 0.01
            :deviceData.screenHeight*0.001,
        left: deviceData.screenWidth * 0.04,
        right: deviceData.screenWidth * 0.05,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: senderId == friend.userId
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: <Widget>[
          senderId == friend.userId
              ? showFriendImage == true
              ? AvatarIcon(
            user: friend,
            radius: 0.03,
            errorWidgetColor: kBackgroundColor,
            placeholderColor: kBackgroundColor,
          )
              : SizedBox(width: deviceData.screenHeight * 0.03)
              : SizedBox.shrink(),
          senderId == friend.userId
              ? SizedBox(width: deviceData.screenWidth * 0.02)
              : SizedBox.shrink(),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (senderId == friend.userId ? [Colors.white54, Colors.white54]
                      : [Colors.purple, Colors.deepPurple]),
    ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(senderId == friend.userId
                        ? showFriendImage == true
                        ? deviceData.screenWidth * 0.02
                        : deviceData.screenWidth * 0.02
                        : deviceData.screenWidth * 0.09),
                    topRight: Radius.circular(senderId != friend.userId
                        ? lastsendermsg == true
                        ? deviceData.screenWidth * 0.02
                        : deviceData.screenWidth * 0.02
                        : deviceData.screenWidth * 0.09),
                    bottomRight: Radius.circular(senderId == friend.userId
                        ? deviceData.screenWidth * 0.09
                        : lastsendermsg == true
                        ? deviceData.screenWidth * 0.09
                        : deviceData.screenWidth * 0.02),
                    bottomLeft: Radius.circular(senderId != friend.userId
                        ? deviceData.screenWidth * 0.09
                        : showFriendImage == true
                        ? deviceData.screenWidth * 0.09
                        : deviceData.screenWidth * 0.02),
                  )),

              padding: EdgeInsets.symmetric(
                  vertical: deviceData.screenHeight * 0.010,
                  horizontal: deviceData.screenHeight * 0.015),
              child: Container(
                  child: Text(
                message,
                style: TextStyle(
                  fontSize: deviceData.screenHeight * 0.015,
                  color:
                  senderId != friend.userId ? Colors.white : Colors.black,
                ),
              ),)

            ),
          ),

        ],
      )));
  }
}