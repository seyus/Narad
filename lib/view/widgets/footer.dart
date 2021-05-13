import 'package:flutter/material.dart';
import 'package:narad/view/utils/device_config.dart';

class WhiteFooter extends StatelessWidget {
  const WhiteFooter({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return Container(
      width: deviceData.screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(0.0, 0.0),
            blurRadius: 50.0,
            spreadRadius: 1.0,
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(deviceData.screenWidth * 0.2),
        ),
      ),
    );
  }
}