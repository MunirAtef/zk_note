

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zk_note/firebase/auth.dart';
import 'package:zk_note/screens/choose_login_type/choose_login_type_ui.dart';
import 'package:zk_note/screens/home_page/home_page_ui.dart';
import 'package:zk_note/screens/register/complete_registration.dart';
import 'package:zk_note/shared/user_data.dart';


class LoginState {
  bool passHidden;
  bool loadingEmail;
  bool loadingGoogle;

  LoginState({
    this.passHidden = true,
    this.loadingEmail = false,
    this.loadingGoogle = false
  });

  LoginState change({
    bool? passHidden,
    bool? loadingEmail,
    bool? loadingGoogle
  }) {
    return LoginState(
      passHidden: passHidden ?? this.passHidden,
      loadingEmail: loadingEmail ?? this.loadingEmail,
      loadingGoogle: loadingGoogle ?? this.loadingGoogle
    );
  }
}


class LoginCubit extends Cubit<LoginState> {
  LoginCubit(): super(LoginState());

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  void changePassVisibility() {
    emit(state.change(passHidden: !state.passHidden));
  }

  Future<void> loginWithEmail(BuildContext context) async {
    String email = emailController.text.trim();
    String pass = passController.text;
    NavigatorState navigator = Navigator.of(context);

    if (!isEmailValid(email)) return toastEnd("Invalid email");
    if (pass.length < 4) return toastEnd("Too short password");

    FocusScope.of(context).unfocus();

    emit(state.change(loadingEmail: true, loadingGoogle: false));
    User? user = await Auth.loginWithEmail(context, email, pass);

    if (user != null) {
      bool isRegistered = await UserData.getData(user.uid);

      navigator.pushReplacement(MaterialPageRoute(
        builder: (context) => isRegistered?
          const HomePage()
          : const CompleteRegistration()
      ));
    }

    // emit(state.change(loadingEmail: false, loadingGoogle: false));
  }

  bool isEmailValid(String email) {
    /// Regular expression pattern for email validation
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return emailRegex.hasMatch(email);
  }

  void backToLoginType(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ChooseLoginType()
      )
    );
  }

  void toastEnd(String msg) => Fluttertoast.showToast(msg: msg);
}



