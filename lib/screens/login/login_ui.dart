
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/screens/login/login_cubit.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import 'package:zk_note/shared_widgets/custom_text_field.dart';
import 'package:zk_note/shared_widgets/login_background.dart';

import '../../shared/font_family.dart';
import '../../shared/main_colors.dart';


class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // final LoginCubit cubit = BlocProvider.of<LoginCubit>(context);
    final LoginCubit cubit = LoginCubit();
    const Color subColor = Colors.pink;

    return BlocProvider(
      create: (context) => cubit,
      child: LoginBackground(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: BlocBuilder<LoginCubit, LoginState>(
            builder: (BuildContext context, LoginState state) {
              return Column(
                children: [
                  const Text(
                    "LOGIN",
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

                  CustomTextField(
                    controller: cubit.passController,
                    hint: "Password",
                    prefix: const Icon(Icons.lock),
                    margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    hideText: state.passHidden,
                    suffix: IconButton(
                      onPressed: () => cubit.changePassVisibility(),
                      icon: state.passHidden?
                        const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                      )
                  ),

                  CustomButton(
                    text: "NEXT",
                    leading: const Icon(
                      Icons.arrow_circle_right_outlined,
                      color: Colors.white
                    ),
                    isLoading: state.loadingEmail,
                    color: subColor,
                    margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                    onPressed: () async => await cubit.loginWithEmail(context),
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
              );
            },
          ),
        )
      ),
    );
  }
}







