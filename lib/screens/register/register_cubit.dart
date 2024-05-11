

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zk_note/firebase/auth.dart';
import 'package:zk_note/firebase/firestore.dart';
import 'package:zk_note/firebase/storage.dart';
import 'package:zk_note/screens/home_page/home_page_ui.dart';
import 'package:zk_note/screens/register/complete_registration.dart';
import 'package:zk_note/screens/register/register_state.dart';
import 'package:zk_note/shared/pick_image.dart';
import 'package:zk_note/shared/user_data.dart';

import '../choose_login_type/choose_login_type_ui.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(): super(RegisterState());

  static RegisterCubit getInstance(BuildContext context) =>
    BlocProvider.of<RegisterCubit>(context);

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  TextEditingController marketplaceController = TextEditingController();

  bool isPassHidden = true;
  bool isConfirmHidden = true;
  bool isRegisterLoading = false;
  bool isComRegisterLoading = false;

  File? marketplaceLogo;

  void updatePassVisibility() {
    isPassHidden = !isPassHidden;
    emit(RegisterState(updatePassVisibility: true));
  }

  void updateConfirmVisibility() {
    isConfirmHidden = !isConfirmHidden;
    emit(RegisterState(updateConfirmVisibility: true));
  }

  Future<void> registerWithEmail(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passController.text;
    String confirm = confirmController.text;

    NavigatorState navigator = Navigator.of(context);

    if (!Auth.isValidEmail(email)) {
      Fluttertoast.showToast(msg: "The email is not valid");
      return;
    }
    if (password.length < 8) {
      Fluttertoast.showToast(msg: "Password is too short");
      return;
    }
    if (password != confirm) {
      Fluttertoast.showToast(msg: "Two passwords not matching");
      return;
    }
    FocusScope.of(context).unfocus();

    isRegisterLoading = true;
    emit(RegisterState(updateRegisterLoading: true));
    User? user = await Auth.registerWithEmail(context, email, password);
    isRegisterLoading = false;

    if (user != null) {
      UserData.uid = user.uid;
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CompleteRegistration()
        )
      );
    }

    emit(RegisterState(updateRegisterLoading: true));
  }

  Future<bool> onWillPop() async {
    if (isRegisterLoading) return false;

    emailController.clear();
    passController.clear();
    confirmController.clear();

    return true;
  }

  void backToLoginType(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ChooseLoginType()
      )
    );
  }

  void uploadImage(BuildContext context) async {
    File? pickedImage = await PickImage.pickImage(
      context: context,
      color: Colors.pink,
      onDelete: marketplaceLogo == null? null: () {
        marketplaceLogo = null;
        emit(RegisterState(updateMarketplaceLogo: true));
      }
    );

    if (pickedImage != null) {
      marketplaceLogo = pickedImage;
      emit(RegisterState(updateMarketplaceLogo: true));
    }
  }

  Future<void> completeRegister(BuildContext context) async {
    String marketplaceName = marketplaceController.text.trim();

    if (marketplaceName.isEmpty) {
      Fluttertoast.showToast(msg: "Enter marketplace name");
      return;
    }
    FocusScope.of(context).unfocus();

    NavigatorState navigator = Navigator.of(context);

    isComRegisterLoading = true;
    emit(RegisterState(updateComRegisterLoading: true));

    String imageExt = marketplaceLogo?.path.split(".").last ?? "";
    String? imageUrl = await Storage.uploadFile(
      path: "${UserData.uid}/marketplaceLogo.$imageExt",
      file: marketplaceLogo
    );

    await Firestore.uploadUserData(marketplaceName, imageUrl);
    clearCompRegister();

    UserData.mpName = marketplaceName;
    UserData.mpLogo = imageUrl;

    navigator.pushReplacement(MaterialPageRoute(
      builder: (context) => const HomePage()
    ));
  }

  void clearRegister() {
    emailController.clear();
    passController.clear();
    confirmController.clear();

    isPassHidden = true;
    isConfirmHidden = true;
    isRegisterLoading = false;
  }

  void clearCompRegister() {
    marketplaceController.clear();
    isComRegisterLoading = false;
    marketplaceLogo = null;
  }
}
