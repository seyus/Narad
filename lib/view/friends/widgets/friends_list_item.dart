
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:narad/models/user_presentation.dart';
import 'package:narad/utils/functions.dart';
import 'package:narad/view/friends/bloc/friends_bloc.dart';
import 'package:narad/view/friends/widgets/friends_profile.dart';
import 'package:narad/view/messages/widgets/messages_screen.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/avatar_icon.dart';
import 'package:page_transition/page_transition.dart';

class FriendsListItem extends StatelessWidget {
  const FriendsListItem({
    Key key,
    @required this.user,
  }) : super(key: key);
  final UserPresentation user;

  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    if(user.lastMessage!=null)
    return InkResponse(

      onLongPress: () {
        FocusScope.of(context).unfocus();
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: FriendsProfileScreen(friend: user)));
      },
      onTap: () {
        if (!KeyboardVisibilityController().isVisible) {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: MessagesScreen(friend: user, user: user)))
              .then((value) {
            if (BlocProvider.of<FriendsBloc>(context).state is SearchSucceed) {
              print(0);
              BlocProvider.of<FriendsBloc>(context).add(ClearSearch());
            }
          });
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 300),
        tween: Tween<double>(begin: -1, end: 1),
        builder: (BuildContext context, double value, Widget child) {
          return Transform.scale(

            scale: value,
              child:Container(
                decoration: BoxDecoration(
                  gradient: user.lastMessageSeen == true?
                  LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple]
                  )
                      : LinearGradient(
                      colors: [Colors.deepPurple, Colors.deepPurple]
                  )
                ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: deviceData.screenHeight * 0.01,
                      top: deviceData.screenHeight * 0.01,
                      left: deviceData.screenWidth * 0.05,
                      right: deviceData.screenWidth * 0.05,
                    ),
                  child: Row(
                children: <Widget>[
                  AvatarIcon(
                    radius: 0.07,
                    user: user,
                    errorWidgetColor: kBackgroundColor,
                    placeholderColor: kBackgroundColor,
                  ),
                  SizedBox(width: deviceData.screenWidth * 0.045),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user.name,
                              style: kArialFontStyle.copyWith(
                                  fontSize: deviceData.screenHeight * 0.0165),
                            ),
                            user.lastMessage != null
                                ? Text(
                                Functions.convertDate(user.lastMessageTime),
                                style: TextStyle(
                                    fontWeight: user.lastMessage != null
                                        ? user.lastMessageSeen == true
                                        ? FontWeight.w400
                                        : FontWeight.bold
                                        : FontWeight.w400,
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize:
                                    deviceData.screenHeight * 0.015))
                                : SizedBox.shrink(),
                          ],
                        ),
                        SizedBox(height: deviceData.screenHeight * 0.01),
                        Container(

                            child: Text(
                          user.lastMessage == null
                              ? "Send a message to start a convo"
                              : user.userId == user.lastMessageSenderId
                              ? Functions.shortenMessage(
                                  user.lastMessage, 30)
                              : "You" +
                              " : " +
                              Functions.shortenMessage(
                                  user.lastMessage, 30),
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: user.lastMessage != null
                                  ? user.lastMessageSeen == true
                                  ? FontWeight.w400
                                  : FontWeight.bold
                                  : FontWeight.w400,
                              color: Colors.white.withOpacity(0.8),
                              fontSize: deviceData.screenHeight * 0.015),
                        ),)
                      ],
                    ),
                  ),
                ],
              ),)
            ),
          );
        },
      ),
    );
    else{
      return SizedBox.shrink();
    }
  }
}