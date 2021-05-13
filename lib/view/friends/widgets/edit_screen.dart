import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narad/models/user.dart';
import 'package:narad/utils/failure.dart';
import 'package:narad/utils/functions.dart';
import 'package:narad/view/register/bloc/account_bloc.dart';
import 'package:narad/view/widgets/progress_indicator.dart';
import 'package:narad/view/widgets/try_again_button.dart';

import 'edit_from_view.dart';

class EditScreen extends StatefulWidget {
  const EditScreen();
  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  MUser user;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) {
        _mapStateToAction(state);
      },
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (BuildContext context, state) {
          return Stack(
            children: [
              user != null
                  ? EditFormView(user: user)
                  : state is FetchProfileFailed &&
                  state.failure is NetworkException
                  ? TryAgain(
                doAction: () => context
                    .read<AccountBloc>()
                    .add(FetchProfileEvent()),
              )
                  : SizedBox.shrink(),
              state is EditAccountLoading || state is FetchProfileLoading
                  ? const Center(child: CircleProgress())
                  : const SizedBox.shrink()
            ],
          );
        },
      ),
    );
  }

  void _mapStateToAction(AccountState state) {
    if (Functions.modalIsShown) {
      Navigator.pop(context);
      Functions.modalIsShown = false;
    }
    if (state is EditAccountSucceed) {
      user = state.user;
    } else if (state is FetchProfileSucceed) {
      user = state.user;
    } else if (state is FetchProfileFailed) {
      Functions.showBottomMessage(context, state.failure.code);
    }
    if (state is EditAccountLoading) {
      Functions.showBottomMessage(context, "Saving ..");
    } else if (state is EditAccountFailed) {
      Functions.showBottomMessage(context, state.failure.code);
    }
  }
}