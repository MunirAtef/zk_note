
import 'package:flutter/material.dart';
import 'package:zk_note/shared/font_family.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import '../../shared/assets.dart';
import '../../shared/main_colors.dart';
import '../../shared_widgets/custom_container.dart';
import '../../shared_widgets/login_background.dart';
import 'choose_login_type_cubit.dart';


class ChooseLoginType extends StatelessWidget {
  const ChooseLoginType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChooseLoginTypeCubit cubit = ChooseLoginTypeCubit.getInstance(context);
    const subColor = Colors.pink;

    return LoginBackground(
      body: Column(
        children: [
          const Text(
            "WELCOME TO",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: MainColors.appColorDark,
              fontFamily: FontFamily.handWriting
            ),
          ),

          // const Text(
          //   "ZK",
          //   style: TextStyle(
          //     fontSize: 40,
          //     color: subColor,
          //     fontFamily: FontFamily.princetown
          //   ),
          // ),
          //
          // const SizedBox(height: 10),
          //
          // const Text(
          //   "invoicement",
          //   style: TextStyle(
          //     fontSize: 35,
          //     color: subColor,
          //     fontFamily: FontFamily.princetown
          //   ),
          // ),

          CustomContainer(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            shadowColor: Colors.grey[600]!,
            child: Image.asset(AssetImages.appIcon),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: () => cubit.navToLogin(context),
                  margin: const EdgeInsets.only(left: 20, bottom: 15),
                  padding: const EdgeInsets.symmetric(vertical: 5),

                  color: subColor,
                  text: "LOGIN",
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30)
                  ),
                  // width: width / 2 - 30,
                ),
              ),

              Expanded(
                child: CustomButton(
                  onPressed: () => cubit.navToSignup(context),
                  margin: const EdgeInsets.only(right: 20, bottom: 15),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  color: subColor,
                  text: "SIGNUP",
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30)
                  ),
                ),
              ),
            ],
          ),

          Row(
            children: const [
              Expanded(child: Divider(indent: 30, endIndent: 10, thickness: 3)),
              Text("OR", style: TextStyle(fontWeight: FontWeight.w600)),
              Expanded(child: Divider(indent: 10, endIndent: 30, thickness: 3))
            ],
          ),

          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: () async => await cubit.loginWithGoogle(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: subColor,
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.fromLTRB(10, 10, 15, 10),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))
              ),
              side: BorderSide(width: 3, color: Colors.grey[300]!),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600
              )
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AssetImages.googleIcon, width: 25, height: 25),
                const SizedBox(width: 10),
                const Text("CONTINUE WITH GOOGLE")
              ],
            )
          )
        ],
      ),
    );
  }
}

