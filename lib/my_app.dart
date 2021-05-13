import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narad/service_locator.dart';
import 'package:narad/view/register/bloc/account_bloc.dart';
import 'package:narad/view/splash/splash_screen.dart';
import 'package:narad/view/utils/constants.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountBloc>(
            create: (_) =>
            serviceLocator<AccountBloc>()..add(IsSignedInEvent())),
        // BlocProvider<NotificationBloc>(
        //     create: (_) => serviceLocator<NotificationBloc>()
        //     ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          accentColor: kBackgroundColor,
        ),
        initialRoute: '/',
        routes: {
          '/':(context)=>SplashScreen(),
        },
      ),
    );
  }
}