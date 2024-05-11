
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zk_note/firebase/auth.dart';
import 'package:zk_note/firebase/firestore.dart';
import 'package:zk_note/screens/choose_login_type/choose_login_type_ui.dart';
import 'package:zk_note/screens/home_page/home_page_state.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/pick_image.dart';
import 'package:zk_note/shared_widgets/confirm_dialog.dart';
import 'package:zk_note/shared_widgets/input_dialog.dart';
import 'package:zk_note/shared_widgets/loading_dialog.dart';

import '../../firebase/storage.dart';
import '../../shared/assets.dart';
import '../../shared/user_data.dart';


class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit(): super(HomePageState());

  static HomePageCubit getInstance(BuildContext context) =>
    BlocProvider.of<HomePageCubit>(context);

  int routeIndex = 0;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final Color subColor = MainColors.drawer;

  void updateRoute(int index) {
    if (index != routeIndex) {
      routeIndex = index;
      emit(HomePageState(updateRoute: true));
    }
  }

  Future<bool> onWillPop() async {
    if (scaffoldKey.currentState?.isDrawerOpen == true) return true;
    if (routeIndex == 0) return true;
    routeIndex = 0;
    emit(HomePageState(updateRoute: true));
    return false;
  }

  void updateMarketplaceLogo(BuildContext context) async {
    NavigatorState navigator = Navigator.of(context);

    File? pickedImage = await PickImage.pickImage(
      context: context,
      color: subColor,
      onDelete: UserData.mpLogo == null? null: () async {
        navigator.pop();

        showLoading(
          context: context,
          title: "DELETING IMAGE",
          color: subColor,
          waitFor: () async {
            await Firestore.updateMpLogo(null);
            UserData.mpLogo = null;
            emit(HomePageState(updateMpLogo: true));
          }
        );
      }
    );

    if (pickedImage != null) {
      String imageExt = pickedImage.path.split(".").last;
      showLoading(
        context: context,
        title: "UPDATING IMAGE",
        color: subColor,
        waitFor: () async {
          String? imageUrl = await Storage.uploadFile(
            path: "${UserData.uid}/marketplaceLogo.$imageExt",
            file: pickedImage
          );

          await Firestore.updateMpLogo(imageUrl);
          UserData.mpLogo = imageUrl;
          emit(HomePageState(updateMpLogo: true));
        }
      );
    }
  }

  void updateMarketplaceName(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => InputDialog(
        color: subColor,
        title: "UPDATE MARKETPLACE NAME",
        hint: "Enter marketplace name",
        defaultText: UserData.mpName,
        prefix: const ImageIcon(AssetImage(AssetImages.miniMarketplace)),
        onConfirm: (String name) async {
          if (name.isEmpty) {
            Fluttertoast.showToast(msg: "No name entered");
            return false;
          }

          await Firestore.updateMpName(name);
          UserData.mpName = name;
          emit(HomePageState(updateMpName: true));
          return true;
        },
      )
    );
  }

  Future<void> signOut(BuildContext context) async {
    NavigatorState navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: "LOGOUT",
        content: "Are you sure you want to logout fro m this account?",
        color: subColor,
        onConfirm: () async {
          await Auth.signOut();
          UserData.clear();

          navigator.pop();
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ChooseLoginType()
            )
          );

          return false;
        },
      )
    );
  }


  void contactLinkedin() {
    launchUrl(
      Uri.parse("https://www.linkedin.com/in/munir-m-atef-573255215"),
      mode: LaunchMode.externalApplication
    );
  }

  void contactWhatsapp() {
    launchUrl(
      Uri.parse("https://wa.me/+201146721499"),
      mode: LaunchMode.externalApplication
    );
  }

  void contactFacebook() {
    launchUrl(
      Uri.parse("https://www.facebook.com/munir-atef.52"),
      mode: LaunchMode.externalApplication
    );
  }

  void contactGmail() {
    launchUrl(
      Uri.parse("mailto:munir.atef1729@gmail.com?to=&subject=&body=Hi Munir, "),
      mode: LaunchMode.externalApplication
    );
  }
}
