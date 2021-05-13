import 'package:flutter/material.dart';
import 'package:narad/view/utils/device_config.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({
    Key key,
    @required this.controller,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Material(
      borderRadius: BorderRadius.all(
        Radius.circular(deviceData.screenWidth * 0.05),
      ),
      child: Container(
        width: deviceData.screenWidth * 0.75,
        color: Colors.transparent,
        child: TextField(
          textCapitalization: TextCapitalization.sentences,
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          textInputAction: TextInputAction.newline,
          cursorColor: Colors.black,
          style: TextStyle(
            fontSize: deviceData.screenHeight * 0.018,
          ),
          decoration: InputDecoration(
            isDense: true,
            fillColor: Colors.amber,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(
                  Radius.circular(deviceData.screenWidth * 0.05)),
            ),
            hintText: "type your message",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}