import 'package:edge_alert/edge_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
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


class SignInForm extends StatefulWidget {
  const SignInForm({
    Key key,
    @required this.scaffoldContext,
  }) : super(key: key);
  final BuildContext scaffoldContext;

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm>
    with AutomaticKeepAliveClientMixin {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email, password;
  Failure failure;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final deviceData = DeviceData.init(context);
    return BlocListener<AccountBloc, AccountState>(
      listener: (_, state) => _mapStateToActions(widget.scaffoldContext, state),
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
                        errorText:
                        failure is EmailException ? failure.code : null,
                        inputTitle: "Email",
                        leading: Icons.mail,
                        hintText: "Enter your Registered email",
                        inputType: TextInputType.emailAddress,
                        onSaved: (value) {
                          email = value;
                        },
                      ),
                      SizedBox(height: 0),
                      InputField(
                        inputTitle: "Password",
                        leading: Icons.lock,
                        hintText: "Enter Password",
                        errorText:
                        failure is PasswordException ? failure.code : null,
                        obscureText: true,
                        isLastField: true,
                        onSubmitted: (value) {
                          _onSubmit();
                        },
                        onSaved: (value) {
                          password = value;
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                          onTap: () {
                            resetPassword(email);
                          },
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.deepPurple),
                          )),
                      SizedBox(height: 30),
                      RoundedButton(
                          text: "Login",
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

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  void _onSubmit() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      context
          .read<AccountBloc>()
          .add(SigninEvent(email: email, password: password));
    }
  }

  void _mapStateToActions(BuildContext scaffoldContext, AccountState state) {
    failure = NoException();
    loading = false;
    if (Functions.modalIsShown) {
      Navigator.pop(context);
      Functions.modalIsShown = false;
    }
    if (state is SigninFailed) {
      failure = state.failure;
      EdgeAlert.show(context,
          title: 'Login Failed',
          description: failure.code.toString(),
          gravity: EdgeAlert.BOTTOM,
          icon: Icons.error,
          backgroundColor: Colors.red);

    } else if (state is SigninLoading) {
      Functions.showBottomMessage(context, "Signing in ...",
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