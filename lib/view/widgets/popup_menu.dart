import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:narad/models/user.dart';
import 'package:narad/view/friends/widgets/edit_screen.dart';
import 'package:narad/view/music/music_screen.dart';
import 'package:narad/view/register/bloc/account_bloc.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:page_transition/page_transition.dart';

class PopUpMenu extends StatelessWidget {
  const PopUpMenu({
    Key key,@required this.onPressed, @required this.user,
  }) : super(key: key);
  final Function onPressed;
  final MUser user;

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);

    return Container(
      width: deviceData.screenHeight * 0.05,
      height: deviceData.screenHeight * 0.05,
      child: PopupMenuButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        icon: Icon(
          Feather.more_vertical,
          color: Colors.white,
          size: deviceData.screenWidth * 0.058,
        ),
        color: kBackgroundButtonColor,
        onSelected: (value) {
          if (value == "logout") {
            BlocProvider.of<AccountBloc>(context).add(LogOutEvent());
          }
          if (value == "music") {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: MusicScreen(user: user)));
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<String>(
              value: "logout",
              child: Center(
                child: Text(
                  "Log out",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "music",
              child: Center(
                child: Text(
                  "NARAD MUSIC",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    );
  }
}