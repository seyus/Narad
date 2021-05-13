import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:narad/models/message.dart';
import 'package:narad/models/user.dart';
import 'package:narad/models/user_presentation.dart';
import 'package:narad/utils/functions.dart';
import 'package:narad/view/messages/bloc/messages_bloc.dart';
import 'package:narad/view/messages/widgets/send_icon.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/progress_indicator.dart';

import 'message_input.dart';
import 'message_item.dart';

class MessagesList extends StatefulWidget {
  final MUser friend;
  final UserPresentation user;
  final bool block;
  MessagesList({
    @required this.friend, @required this.user, @required this.block
  });

  @override
  _MessagesListState createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  TextEditingController _textController;
  List<Message> messages;
  ScrollController _scrollController = ScrollController();
  bool noMoreMessages = false;
  File pickedImage;
  bool imageIsPicked = false;
  bool isLoading;
  String imageUrl;

  @override
  void initState() {
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(() => _scrollListener());
    imageUrl = '';
    super.initState();
  }

  Future getImage() async {
    try {
      final pickedFile =
      await ImagePicker().getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageIsPicked = true;
        setState(() {
          pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {}
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        !noMoreMessages) {
      context.read<MessagesBloc>().add(MoreMessagesFetched(
          _scrollController.position.pixels, messages.length));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return BlocConsumer<MessagesBloc, MessagesState>(
        listener: (context, state) {
          _mapStateToActions(state);
        }, builder: (_, state) {
      if (messages != null) {
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding:
                    EdgeInsets.only(bottom: deviceData.screenHeight * 0.01),
                    child: Stack(
                    children: [
                    messages.length < 1
                        ? Center(
                        child: Text("No messages yet ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: deviceData.screenHeight * 0.019,
                              color: kBackgroundButtonColor,
                            )))
                        : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          final message = messages[index];
                          return MessageItem(
                            user: widget.friend,
                            showFriendImage:
                            _showFriendImage(message, index),
                            lastsendermsg:
                            _lastsendermsg(message, index),
                            friend: widget.friend,
                            message: message.message,
                            senderId: message.senderId,
                          );
                        }),


                    state is MoreMessagesLoading
                      ? Padding(
                    padding: EdgeInsets.only(
                        top: deviceData.screenHeight * 0.01),
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: const CircleProgress(
                          radius: 0.035,
                        )),
                  )
                      : SizedBox.shrink(),
      ],
      ),),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: deviceData.screenHeight * 0.02,
                left: deviceData.screenWidth * 0.07,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  MessageInput(controller: _textController),
                  SendIcon(
                    controller: _textController,
                    friendId: widget.friend.userId,
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  bool _showFriendImage(Message message, int index) {
    if (message.senderId == widget.friend.userId) {
      if (index == 0) {
        return true;
      } else if (index > 0) {
        String nextSender = messages[index - 1].senderId;
        if (nextSender == widget.friend.userId) {
          return false;
        } else {
          return true;
        }
      }
    }
    return true;
  }

  bool _lastsendermsg(Message message, int index) {
    if (message.senderId != widget.friend.userId) {
      if (index == 0) {
        return true;
      } else if (index > 0) {
        String nextSender = messages[index - 1].senderId;
        if (nextSender != widget.friend.userId) {
          return false;
        } else {
          return true;
        }
      }
    }
    return false;
  }

  void _mapStateToActions(MessagesState state) {
    if (Functions.modalIsShown) {
      Navigator.pop(context);
      Functions.modalIsShown = false;
    }

    if (state is MessageSentFailure) {
      Functions.showBottomMessage(context, state.failure.code);
    } else if (state is MessagesLoadFailed) {
      Functions.showBottomMessage(context, state.failure.code);
    } else if (state is MessagesLoadSucceed) {
      if (_scrollController.hasClients) {
        _scrollController?.jumpTo(state.scrollposition);
      }
      if (state.noMoreMessages != null) {
        noMoreMessages = state.noMoreMessages;
      }
      messages = state.messages;
      _textController.clear();
    } else if (state is MoreMessagesFailed) {
      Functions.showBottomMessage(context, state.failure.code);
    }
  }
}