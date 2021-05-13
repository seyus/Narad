import 'package:flutter/material.dart';
import 'package:narad/models/user.dart';
import 'package:narad/view/music/music_api_saavn.dart';
import 'package:narad/view/utils/device_config.dart';


class MBackIcon extends StatelessWidget {
  const MBackIcon({
    Key key, @required this.user,
  }) : super(key: key);

  final MUser user;

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return GestureDetector(
      onTap: () {
        searchedList = [];
      },
      child: Container(
        padding: EdgeInsets.all(deviceData.screenHeight * 0.025),
        child: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
          size: deviceData.screenWidth * 0.058,
        ),
      ),
    );
  }
}