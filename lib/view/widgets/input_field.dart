import 'package:flutter/material.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';

class InputField extends StatelessWidget {
  final String inputTitle;
  final String hintText;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final Function onSubmitted;
  final bool isLastField;
  final String initalText;
  final Function onSaved;
  final Function onChanged;
  final OnValidator onValidator;
  final String errorText;
  final bool enabled;
  final bool obscureText;
  final Widget inputIcon;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final IconData leading;
  final TextInputType keyboard;
  final Color color;
  InputField({
    this.color = Colors.white,
    this.keyboard=TextInputType.text,
    this.leading,
    this.inputTitle,
    this.hintText,
    this.inputType,
    this.inputAction = TextInputAction.next,
    this.isLastField = false,
    this.onSubmitted,
    this.initalText,
    this.onSaved,
    this.errorText,
    this.enabled = true,
    this.onValidator,
    this.onChanged,
    this.obscureText = false,
    this.inputIcon,
    this.textCapitalization,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    DeviceData _deviceData = DeviceData.init(context);
    return Container(
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.only(left: 10),
      width: MediaQuery.of(context).size.width * 0.70,
              child: TextFormField(
                keyboardType: inputType,
                decoration: InputDecoration(
                  icon: Icon(
                    leading,
                    color: Colors.black,
                  ),
                  border: InputBorder.none,
                  hintText: hintText,

                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                  ),
                ),
                textAlign: textAlign ?? TextAlign.start,
                textCapitalization:
                textCapitalization ?? TextCapitalization.none,
                maxLines: obscureText ? 1 : null,
                initialValue: initalText,
                enabled: enabled,
                obscureText: obscureText,
                cursorColor: kButtonColor,
                style: TextStyle(
                  fontSize: _deviceData.screenHeight * 0.017,
                ),
                textInputAction:
                isLastField ? TextInputAction.done : TextInputAction.next,
                onFieldSubmitted: (value) {
                  if (!isLastField) {
                    FocusScope.of(context)
                        .focusInDirection(TraversalDirection.down);
                  } else if (onSubmitted != null) {
                    Future.delayed(Duration(milliseconds: 300), () {
                      onSubmitted(value);
                    });
                  }
                },
                validator: (value) {
                  if (value.isEmpty) {
                    if (obscureText != null && obscureText) {
                      return "Password is empty.";
                    }
                    if (inputType != null &&
                        inputType == TextInputType.emailAddress) {
                      return "Email is empty.";
                    } else if (inputTitle != null) {
                      return "$inputTitle is empty.";
                    }

                    return "This field is empty.";
                  } else if (onValidator != null) {
                    return onValidator(value);
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  if (onSaved != null) {
                    onSaved(value);
                  }
                },
                onChanged: onChanged,
              ),
            );
  }
}

typedef String OnValidator(String value);
