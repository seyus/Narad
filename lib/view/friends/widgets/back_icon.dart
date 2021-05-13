import 'package:flutter/material.dart';
import 'package:narad/view/utils/device_config.dart';
class BackIcon extends StatelessWidget {
  const BackIcon({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Container(
      width: deviceData.screenHeight * 0.05,
      height: deviceData.screenHeight * 0.05,
      child: InkResponse(
        onTap: () {
          if (onPressed != null) {
            onPressed();
          }
        },
        child: Icon(
          Icons.arrow_back_ios_rounded,
          size: deviceData.screenWidth * 0.055,
          color: Colors.white,
        ),
      ),
    );
  }
}