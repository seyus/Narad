import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:narad/view/friends/bloc/friends_bloc.dart';
import 'package:narad/view/utils/device_config.dart';

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  bool _enableSearch = false;
  StreamSubscription<bool> keyboradListener;
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    keyboradListener = KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible == false &&
          _enableSearch == true &&
          _controller.text.length < 1) {
        setState(() {
          _enableSearch = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    keyboradListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FriendsBloc, FriendsState>(
      listener: (context, state) {
        if (state is EmptySearchField) {
          _controller.clear();
          setState(() {
            _enableSearch = false;
          });
        }
      },
      child: WillPopScope(
          onWillPop: () async {
            if (_enableSearch) {
              BlocProvider.of<FriendsBloc>(context).add(ClearSearch());
              return false;
            } else {
              return true;
            }
          },
          child: _enableSearch
              ? SearchField( controller: _controller)
              : SearchIcon(
            onPressed: () {
              setState(() {
                _enableSearch = true;
              });
            },
          )),
    );
  }

}

class SearchField extends StatelessWidget {
  const SearchField({
    @required this.controller,

  }) ;

  final TextEditingController controller;


  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);

    return Container(
      width: deviceData.screenWidth * 0.65,
      child: Stack(
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            autofocus: true,
            cursorColor: Colors.white,
            style: TextStyle(
              color: Colors.white,
              fontSize: deviceData.screenHeight * 0.017,
            ),
            onChanged: (value) {
              BlocProvider.of<FriendsBloc>(context).add(SearchByName(value));
            },
            decoration: InputDecoration(
                hintText: "Enter friend's name",
                hintStyle: TextStyle(
                  color: Colors.white24,
                ),
                fillColor: Colors.black,
                filled: true,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                )),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: deviceData.screenWidth * 0.005),
              child: IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  BlocProvider.of<FriendsBloc>(context).add(ClearSearch());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchIcon extends StatelessWidget {
  const SearchIcon({@required this.onPressed});

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
          Feather.search,
          size: deviceData.screenWidth * 0.055,
          color: Colors.white,
        ),
      ),
    );
  }
}