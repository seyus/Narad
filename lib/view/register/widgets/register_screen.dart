import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narad/utils/functions.dart';
import 'package:narad/view/friends/widgets/friends_screen.dart';
import 'package:narad/view/register/bloc/account_bloc.dart';
import 'package:narad/view/register/widgets/sign_in_form.dart';
import 'package:narad/view/register/widgets/sign_up_form.dart';
import 'package:narad/view/utils/constants.dart';
import 'package:narad/view/utils/device_config.dart';


class RegisterScreen extends StatelessWidget {
  static String routeID = "REGISTER_SCREEN";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Builder(
          builder: (BuildContext scaffoldContext) => Container(
            color: kBackgroundColor,
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          BlocListener<AccountBloc, AccountState>(
                            listener: (context, state) {
                              if (state is RegisterSucceed) {
                                Functions.transition(context, FriendsScreen(),
                                    Duration(milliseconds: 0));
                              }
                            },
                            child: Tabs(scaffoldContext: scaffoldContext),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Tabs extends StatelessWidget {
  const Tabs({
    Key key,
    @required this.scaffoldContext,
  }) : super(key: key);
  final BuildContext scaffoldContext;
  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: deviceData.screenHeight * 0.1,
            child: TabBar(
              onTap: (x) => FocusScope.of(context).unfocus(),
              tabs: [Tab(text: 'Login'), Tab(text: 'Sign up')],
              labelStyle: kArialFontStyle.copyWith(
                fontSize: deviceData.screenHeight * 0.018,
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black38,
              indicatorColor: Colors.transparent,
            ),
          ),
          Expanded(
            child: TabBarView(children: [
              SignInForm(scaffoldContext: scaffoldContext),
              SignUpForm()
            ]),
          ),
        ],
      ),
    );
  }
}