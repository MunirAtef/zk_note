
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/screens/login/login_ui.dart';
import 'package:zk_note/screens/register/complete_registration.dart';
import 'package:zk_note/screens/register/register_ui.dart';
import 'package:zk_note/shared/user_data.dart';

import '../../firebase/auth.dart';
import '../home_page/home_page_ui.dart';

class ChooseLoginTypeCubit extends Cubit<int> {
  ChooseLoginTypeCubit(): super(0);

  static ChooseLoginTypeCubit getInstance(BuildContext context) =>
    BlocProvider.of<ChooseLoginTypeCubit>(context);

  void navToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const Login()
      )
    );
  }

  void navToSignup(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const Register()
      )
    );
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    NavigatorState navigator = Navigator.of(context);

    User? user = await Auth.loginWithGoogle(context);
    if (user != null) {
      bool isRegistered = await UserData.getData(user.uid);

      navigator.pushReplacement(MaterialPageRoute(
        builder: (context) => isRegistered?
          const HomePage()
          : const CompleteRegistration()
      ));

    }
  }
}
