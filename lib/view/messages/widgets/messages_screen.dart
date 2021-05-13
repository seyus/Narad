import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:narad/models/message.dart';
import 'package:narad/models/user.dart';
import 'package:narad/models/user_presentation.dart';
import 'package:narad/utils/failure.dart';
import 'package:narad/view/messages/bloc/messages_bloc.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/progress_indicator.dart';
import 'package:narad/view/widgets/try_again_button.dart';

import '../../../service_locator.dart';
import 'message_header.dart';
import 'messages_list.dart';

class MessagesScreen extends StatefulWidget {
  final MUser friend;
  final UserPresentation user;
  MessagesScreen({@required this.friend, @required this.user});
  static String routeID = "MESSAGE_SCREEN";

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessagesScreen> {
  Future<List<Message>> messagesFuture;
  TextEditingController controller;
  DeviceData deviceData;
  bool showMessages = false;
  MessagesBloc messagesBloc;
  @override
  void initState() {
    messagesBloc = serviceLocator<MessagesBloc>();
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    messagesBloc.close();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceData = DeviceData.init(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.black,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MessagesHeader(friend: widget.friend),
              Expanded(
                child: BlocProvider<MessagesBloc>(
                  create: (context) =>
                  messagesBloc..add(MessagesStartFetching(widget.friend)),
                  child: Stack(
                    children: <Widget>[
                      MessagesList(friend: widget.friend, user: widget.user),
                      BlocBuilder<MessagesBloc, MessagesState>(
                        builder: (context, state) {
                          return state is MessagesLoading
                              ? const Center(child: CircleProgress())
                              : state is MessagesLoadFailed &&
                              state.failure is NetworkException
                              ? TryAgain(
                              doAction: () => context
                                  .read<MessagesBloc>()
                                  .add(MessagesStartFetching(
                                  widget.friend)))
                              : SizedBox.shrink();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}