import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narad/models/user.dart';
import 'package:narad/utils/functions.dart';
import 'package:narad/view/friends/bloc/friends_bloc.dart';
import 'package:narad/view/messages/widgets/messages_screen.dart';
import 'package:narad/view/notification/bloc/notification_bloc.dart';
import 'package:narad/view/register/bloc/account_bloc.dart';
import 'package:narad/view/register/widgets/register_screen.dart';
import 'package:narad/view/widgets/progress_indicator.dart';
import 'package:page_transition/page_transition.dart';

import '../../../service_locator.dart';
import 'edit_screen.dart';
import 'friends_header.dart';
import 'friends_list.dart';

class FriendsScreen extends StatelessWidget {
  static String routeID = "FRIENDS_SCREEN";
  final MUser user;
  FriendsScreen({@required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Color(0xff141414),
          child: FriendsScreenView(user: user),
        ),
      ),
    );
  }
}

class FriendsScreenView extends StatefulWidget {
  final MUser user;
  FriendsScreenView({
    Key key, @required this.user
  }) : super(key: key);

  @override
  _FriendsScreenViewState createState() => _FriendsScreenViewState();
}

class _FriendsScreenViewState extends State<FriendsScreenView> {
  bool editForm = false;
  bool avatarClicked = false;
  FriendsBloc friendsBloc;
  NotificationBloc notificationBloc;

  @override
  void initState() {
    friendsBloc = serviceLocator<FriendsBloc>();
    notificationBloc = serviceLocator<NotificationBloc>()
      ..add(ListenToNotification());
    super.initState();
  }

  @override
  void dispose() {
    notificationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
      create: (context) => notificationBloc,
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (BuildContext context, state) {
          if (state is NotificationRecived) {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: MessagesScreen(friend: state.user)));
          }
        },
        child: BlocProvider<FriendsBloc>(
          create: (BuildContext context) => friendsBloc,
          child: WillPopScope(
            onWillPop: () async {
              if (editForm) {
                FocusScope.of(context).unfocus();
                friendsBloc.add(ClearSearch());
                setState(() {
                  editForm = false;
                });
                return false;
              }
              return true;
            },
            child: BlocListener<AccountBloc, AccountState>(
              listener: (context, accountState) {
                _mapAccountStateToActions(accountState);
              },
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      FriendsHeader(
                        onBackPressed: () {
                          FocusScope.of(context).unfocus();
                          friendsBloc.add(ClearSearch());
                          setState(() {
                            editForm = false;
                          });
                        },
                        onAvatarPressed: () {
                          if (!avatarClicked ||
                              context.read<AccountBloc>().state
                              is FetchProfileFailed) {
                            context
                                .read<AccountBloc>()
                                .add(FetchProfileEvent());
                            avatarClicked = true;
                          }
                          if (!editForm) {
                            setState(() {
                              editForm = true;
                            });
                          }
                        },
                        editForm: editForm,
                        user: widget.user,
                      ),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            
                            IndexedStack(
                              index: editForm ? 0 : 1,
                              children: [EditScreen(), FriendsList()],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // // show circular progress when Account Loading state appear
                  BlocBuilder<AccountBloc, AccountState>(
                    builder: (BuildContext context, state) {
                      return state is LogOutLoading
                          ? const Center(child: CircleProgress())
                          : const SizedBox.shrink();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _mapAccountStateToActions(AccountState state) {
    if (Functions.modalIsShown) {
      Navigator.pop(context);
      Functions.modalIsShown = false;
    }
    if (state is LogOutSucceed) {
      Future.delayed(Duration(milliseconds: 200), () async {
        await Navigator.pushReplacement(
            context,
            PageTransition(
                child: RegisterScreen(), type: PageTransitionType.fade));
      });
    } else if (state is LogOutFailed) {
      Functions.showBottomMessage(context, state.failure.code);
    }
  }
}