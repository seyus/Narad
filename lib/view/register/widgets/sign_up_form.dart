import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narad/utils/failure.dart';
import 'package:narad/utils/functions.dart';
import 'package:narad/view/register/bloc/account_bloc.dart';
import 'package:narad/view/utils/device_config.dart';
import 'package:narad/view/widgets/button_widget.dart';
import 'package:narad/view/widgets/fade_in_widget.dart';
import 'package:narad/view/widgets/input_field.dart';
import 'package:narad/view/widgets/progress_indicator.dart';
import 'package:narad/view/widgets/verify.dart';


class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key key,
  }) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm>
    with AutomaticKeepAliveClientMixin {
  String username, email, password;
  final _formKey = GlobalKey<FormState>();
  Failure failure;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);

    DeviceData deviceData = DeviceData.init(context);

    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) => _mapStateToActions(state),
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) => Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Logo(),
                      SizedBox(height: deviceData.screenHeight * 0.04),
                      InputField(
                        inputType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.words,
                        inputTitle: "Username",
                        leading: Icons.text_format,
                        hintText: "Enter user name",
                        onSaved: (value) {
                          username = value;
                        },
                      ),
                      SizedBox(height: 0),
                      InputField(
                        inputTitle: "Email",
                        leading: Icons.mail,
                        inputType: TextInputType.emailAddress,
                        hintText: "Enter your email",
                        onSaved: (value) {
                          email = value;
                        },
                        errorText:
                        failure is EmailException ? failure.code : null,
                      ),
                      SizedBox(height: 0),
                      InputField(
                        inputTitle: "Password",
                        leading: Icons.lock,
                        obscureText: true,
                        hintText: "Enter password",
                        onSaved: (value) {
                          password = value;
                        },
                        errorText:
                        failure is PasswordException ? failure.code : null,
                      ),
                      SizedBox(height: 0),
                      InputField(
                        inputTitle: "Confirm password",
                        leading: Icons.lock,
                        obscureText: true,
                        hintText: "Enter password again",
                        isLastField: true,
                        onValidator: (value) {
                          if (password != value) {
                            return 'The passwords are not matched';
                          }
                          return null;
                        },
                        onSubmitted: (value) {
                          _onSubmit();
                        },
                      ),
                      SizedBox(height: 30),
                      RoundedButton(
                          text: "Sign up",
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _onSubmit();
                          }),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Hero(
                        tag: 'footer',
                        child: Text(
                          'Made with ♥ by Mradul',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            loading
                ? Padding(
              padding:
              EdgeInsets.only(bottom: deviceData.screenHeight * 0.3),
              child: Center(child: const CircleProgress()),
            )
                : Container()
          ],
        ),
      ),
    );
  }

  void _onSubmit() async{
    _formKey.currentState.save();
    final valid = await usernameCheck(username);
    if (_formKey.currentState.validate()) {
      if (valid) {
        BlocProvider.of<AccountBloc>(context).add(
            SignupEvent(email: email, password: password, username: username));
            Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => VerifyScreen(email: email)),
                    );
      }
      else {
        Functions.showBottomMessage(context, "Username already exits");
      }
    }

  }

  Future<bool> usernameCheck(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }

  void _mapStateToActions(AccountState state) {
    failure = NoException();
    loading = false;
    if (Functions.modalIsShown) {
      Navigator.pop(context);
      Functions.modalIsShown = false;
    }
    if (state is SignupFailed) {
      failure = state.failure;
      if (state.failure is BottomPlacedException) {
        Functions.showBottomMessage(context, failure.code);
      }
    } else if (state is SignupLoading) {
      Functions.showBottomMessage(context, "Signing up ... ",
          isDismissible: false);
      loading = true;
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class Logo extends StatelessWidget {
  const Logo();

  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return FadeIn(
      duration: Duration(milliseconds: 0),
      child: Container(
        child: Image.asset(
          'assets/images/logo.png',
          color: Colors.grey[100],
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.contain,
          width: deviceData.screenWidth * 0.45,
        ),
      ),
    );
  }
}