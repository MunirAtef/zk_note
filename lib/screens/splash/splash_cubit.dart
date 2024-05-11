
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/general/city_handler.dart';
import 'package:zk_note/screens/choose_login_type/choose_login_type_ui.dart';
import 'package:zk_note/screens/home_page/home_page_ui.dart';
import 'package:zk_note/shared/user_data.dart';

import '../register/complete_registration.dart';

class SplashCubit extends Cubit<int> {
  SplashCubit(): super(1);

  String devName = "Munir M. Atef";

  void init(context) async {
    NavigatorState navigator = Navigator.of(context);

    for (int i = 1; i <= devName.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      emit(i);
    }

    await CityHandler.getGovernorates();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await Future.delayed(const Duration(seconds: 3));
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const ChooseLoginType())
      );
      return;
    }
    UserData.token = await user.getIdToken();
    bool isRegistered = await UserData.getData(user.uid);

    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) => isRegistered?
          const HomePage()
          : const CompleteRegistration()
      )
    );
  }
}
