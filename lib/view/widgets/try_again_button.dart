import 'package:flutter/material.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/button_widget.dart';

class TryAgain extends StatelessWidget {
  final Function doAction;
  const TryAgain({Key key, @required this.doAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return Container(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: deviceData.screenWidth * 0.2),
            child: RoundedButton(
                text: "Try again",
                onPressed: () {
                  if (doAction != null) {
                    doAction();
                  }
                }),
          ),
        ));
  }
}