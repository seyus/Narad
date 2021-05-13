import 'package:flutter/material.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';


class DefaultTitle extends StatelessWidget {
  const DefaultTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return Padding(
      padding: EdgeInsets.only(
        top: deviceData.screenHeight * 0.07,
        bottom: deviceData.screenHeight * 0.05,
        left: deviceData.screenWidth * 0.08,
        right: deviceData.screenWidth * 0.08,
      ),
      child: Text(
        "NARAD",
        style: kTitleTextStyle.copyWith(
          fontSize: deviceData.screenHeight * 0.028,
        ),
      ),
    );
  }
}