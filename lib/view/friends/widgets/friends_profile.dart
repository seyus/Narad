import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:narad/models/user.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/avatar_icon.dart';
import 'package:narad/view/widgets/fade_in_widget.dart';


class FriendsProfileScreen extends StatelessWidget {
  final MUser friend;

  const FriendsProfileScreen({Key key, @required this.friend})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);

    return Material(
      color: Colors.black,
        child: SingleChildScrollView(
      child: FadeIn(
        duration: Duration(milliseconds: 500),
        child: Stack(
            children:[
          Container(
          height: deviceData.screenHeight,
              child: friend.imageType == ImageType.assets
                  ? Image(
                image: Image.asset(friend.imgUrl).image,
                fit: BoxFit.cover,
              )
                  : CachedNetworkImage(
                  useOldImageOnUrlChange: true,
                  fadeInDuration: const Duration(microseconds: 100),
                  fadeOutDuration: const Duration(microseconds: 100),
                  imageUrl: friend.imgUrl,
                  placeholder: (context, url) => Opacity(
                    opacity: 0.3,
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: deviceData.screenHeight,
                    ),
                  ),
                  errorWidget: (context, url, error) => Opacity(
                    opacity: 0.3,
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: deviceData.screenHeight,
                    ),
                  ),
                  width: deviceData.screenHeight,
                  height: deviceData.screenHeight,
                  fit: BoxFit.cover),
        ),
            Container(
              height: deviceData.screenHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black26,
                    Colors.black54,
                    Colors.black
                  ]
                )
              ),
              child: new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: new Container(
                  decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),

            child: Form(
          child: Padding(
            padding: EdgeInsets.only(
              left: deviceData.screenWidth * 0.04,
              right: deviceData.screenWidth * 0.04,
            ),
            child: SingleChildScrollView(
              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: deviceData.screenHeight * 0.3),
                  GestureDetector(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        AvatarIcon(
                          user: friend,
                          radius: 0.3,
                          errorWidgetColor: kBackgroundColor,
                          placeholderColor: kBackgroundColor,
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.01),
                  Text(
                    friend.name,
                    style: kArialFontStyle.copyWith(
                      fontSize: deviceData.screenHeight * 0.03,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.05),
                  Text(
                    '"'+friend.bio+'"',
                    style: kArialFontStyle.copyWith(
                      fontSize: deviceData.screenHeight * 0.020,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.05),
                  GestureDetector(
                        onTap: () {
                  Navigator.pop(context);
                  },
                    child: Container(
                      padding: EdgeInsets.all(deviceData.screenHeight * 0.025),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: deviceData.screenWidth * 0.058,
                      ),
                    ),
                  )
                ],
              ),)
            ),
          ),
        ),
            )))],
        ),
      ),
      ),
    );
  }
}