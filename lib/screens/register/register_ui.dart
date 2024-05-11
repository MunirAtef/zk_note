
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/screens/register/register_state.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import 'package:zk_note/shared_widgets/custom_text_field.dart';
import 'package:zk_note/shared_widgets/login_background.dart';

import '../../shared/font_family.dart';
import '../../shared/main_colors.dart';
import 'register_cubit.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegisterCubit cubit = RegisterCubit.getInstance(context);
    const subColor = Colors.pink;

    return WillPopScope(
      onWillPop: cubit.onWillPop,
      child: LoginBackground(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "SIGNUP",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: MainColors.appColorDark,
                fontFamily: FontFamily.handWriting
              ),
            ),

            const SizedBox(height: 10),

            CustomTextField(
              controller: cubit.emailController,
              hint: "Email",
              prefix: const Icon(Icons.email),
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),

            BlocBuilder<RegisterCubit, RegisterState>(
              buildWhen: (ps, cs) => cs.updatePassVisibility,
              builder: (context, state) {
                return CustomTextField(
                  controller: cubit.passController,
                  hint: "Password",
                  hideText: cubit.isPassHidden,
                  prefix: const Icon(Icons.lock),
                  suffix: IconButton(
                    onPressed: cubit.updatePassVisibility,
                    icon: Icon(
                      cubit.isPassHidden? Icons.visibility: Icons.visibility_off,
                    )
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                );
              }
            ),

            BlocBuilder<RegisterCubit, RegisterState>(
              buildWhen: (ps, cs) => cs.updateConfirmVisibility,
              builder: (context, state) {
                return CustomTextField(
                  controller: cubit.confirmController,
                  hint: "Confirm password",
                  hideText: cubit.isConfirmHidden,
                  prefix: const Icon(Icons.lock),
                  suffix: IconButton(
                    onPressed: cubit.updateConfirmVisibility,
                    icon: Icon(
                      cubit.isConfirmHidden? Icons.visibility: Icons.visibility_off,
                    )
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                );
              }
            ),

            BlocBuilder<RegisterCubit, RegisterState>(
              buildWhen: (ps, cs) => cs.updateRegisterLoading,
              builder: (context, state) {

                return CustomButton(
                  text: "NEXT",
                  leading: const Icon(
                    Icons.arrow_circle_right_outlined,
                    color: Colors.white
                  ),
                  isLoading: cubit.isRegisterLoading,
                  color: subColor,
                  margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                  onPressed: () => cubit.registerWithEmail(context),
                );
              }
            ),

            TextButton(
              onPressed: () => cubit.backToLoginType(context),
              style: TextButton.styleFrom(
                foregroundColor: subColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16
                )
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back_ios, size: 18),
                  Text("BACK"),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}
