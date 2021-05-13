import 'package:flutter/material.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton(
      {@required this.text, @required this.onPressed, this.enabled = true});
  final String text;
  final Function onPressed;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    DeviceData _deviceData = DeviceData.init(context);
    return Material(
      elevation: 2,
      shadowColor: kButtonColor,
      borderRadius:
      BorderRadius.all(Radius.circular(50)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurple]
          ),
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
          child: InkWell(
        onTap: () {
          if (enabled) {
            FocusScope.of(context).unfocus();
            onPressed();
          }
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: EdgeInsets.all(15),
          child: Center(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ),
      ),)
    );
  }
}