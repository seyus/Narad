import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narad/view/messages/bloc/messages_bloc.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';

class SendIcon extends StatelessWidget {
  const SendIcon({
    Key key,
    @required this.controller,
    @required this.friendId,
  }) : super(key: key);

  final TextEditingController controller;
  final String friendId;
  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
            top: deviceData.screenHeight * 0.01,
            bottom: deviceData.screenHeight * 0.01,
            right: deviceData.screenWidth * 0.02),
        child: InkResponse(
          child: Icon(
            Icons.send_rounded,
            color: Colors.deepPurple,
            size: deviceData.screenWidth * 0.065,
          ),
          onTap: () async {
            if (controller.text.trim().isNotEmpty) {
              BlocProvider.of<MessagesBloc>(context).add(
                  MessageSent(message: controller.text, friendId: friendId));
            }
          },
        ),
      ),
    );
  }
}