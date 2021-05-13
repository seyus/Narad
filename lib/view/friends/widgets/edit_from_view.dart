

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:narad/models/user.dart';
import 'package:narad/utils/functions.dart';
import 'package:narad/view/register/bloc/account_bloc.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/avatar_icon.dart';
import 'package:narad/view/widgets/button_widget.dart';
import 'package:narad/view/widgets/fade_in_widget.dart';
import 'package:narad/view/widgets/input_field.dart';

import 'choose_avatar_row.dart';

class EditFormView extends StatefulWidget {
  const EditFormView({
    Key key,
    @required this.user,
  }) : super(key: key);

  final MUser user;

  @override
  _EditFormViewState createState() => _EditFormViewState();
}

class _EditFormViewState extends State<EditFormView> {
  final formKey = GlobalKey<FormState>();
  String username;
  String userbio;
  File pickedImage;
  bool imageIsPicked = false;
  String selectedAvatarPath;

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);

    return SingleChildScrollView(
          child: FadeIn(
        duration: Duration(milliseconds: 500),
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.only(
              left: deviceData.screenWidth * 0.11,
              right: deviceData.screenWidth * 0.11,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: deviceData.screenHeight * 0.04),
                  GestureDetector(
                    onTap: () => getImage(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        pickedImage != null
                            ? ClipOval(
                          child: Image.file(
                            pickedImage,
                            width: deviceData.screenHeight * 0.2,
                            height: deviceData.screenHeight * 0.2,
                            fit: BoxFit.cover,
                          ),
                        )
                            : AvatarIcon(
                          user: widget.user,
                          radius: 0.2,
                          errorWidgetColor: kBackgroundColor,
                          placeholderColor: kBackgroundColor,
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.01),
                  Text(
                    widget.user.name,
                    style: kArialFontStyle.copyWith(
                      fontSize: deviceData.screenHeight * 0.025,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.02),
                  Text(
                    "Tap the profile pic to change\nOr\nchoose an avatar from",
                    style: kArialFontStyle.copyWith(
                      fontSize: deviceData.screenHeight * 0.016,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.01),
                  ChooseAvatarRow(
                    user: widget.user,
                    onAvatarSelected: (avatarPath) =>
                    selectedAvatarPath = avatarPath,
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.05),
                  InputField(
                    textAlign: TextAlign.center,
                    leading: Icons.edit,
                    textCapitalization: TextCapitalization.words,
                    inputType: TextInputType.name,
                    initalText: widget.user.name,
                    color: Colors.white38,
                    onSaved: (value) {
                      username = value;
                    },
                    onSubmitted: (value) {
                      onSubmit(context);
                    },
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.03),
                  InputField(
                    textAlign: TextAlign.center,
                    leading: Icons.edit,
                    textCapitalization: TextCapitalization.sentences,
                    inputType: TextInputType.text,
                    initalText: widget.user.bio,
                    color: Colors.white38,
                    onSaved: (value) {
                      userbio = value;
                    },
                    onSubmitted: (value) {
                      onSubmit(context);
                    },
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.04),
                  RoundedButton(
                      text: "Save",
                      onPressed: () {
                        onSubmit(context);
                      }),
                  SizedBox(height: deviceData.screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  Future<bool> usernameCheck(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }

  Future<void> onSubmit(BuildContext context) async {
    formKey.currentState.save();
    final valid = await usernameCheck(username);
    if (!valid) {
      username = widget.user.name;
      Functions.showBottomMessage(context, "Username already exits");
    }
    if (formKey.currentState.validate()) {
      if ((username != widget.user.name ||
          imageIsPicked ||
          selectedAvatarPath != null || userbio != widget.user.bio) && userbio != null) {
        if (!imageIsPicked) {
          if (selectedAvatarPath != null) {
            pickedImage = null;
            BlocProvider.of<AccountBloc>(context).add(EditAccountEvent(
                imgUrl: selectedAvatarPath,
                username: username,
                userbio: userbio,
                userId: widget.user.userId));
            selectedAvatarPath = null;
          } else {
            BlocProvider.of<AccountBloc>(context).add(EditAccountEvent(
                username: username, userbio: userbio, userId: widget.user.userId));
          }
        } else if (imageIsPicked) {
          context.read<AccountBloc>().add(EditAccountEvent(
              photo: pickedImage,
              username: username,
              userbio: userbio,
              userId: widget.user.userId));
          imageIsPicked = false;
        }
      } else {
        Functions.showBottomMessage(
          context,
          "Nothing changed.",
        );
      }
    }
  }
}