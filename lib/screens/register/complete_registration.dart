
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/screens/register/register_cubit.dart';
import 'package:zk_note/shared/assets.dart';
import 'package:zk_note/shared_widgets/custom_text_field.dart';
import 'package:zk_note/shared_widgets/login_background.dart';
import 'package:zk_note/shared_widgets/upload_image.dart';

import '../../shared/font_family.dart';
import '../../shared/main_colors.dart';
import '../../shared_widgets/custom_button.dart';
import 'register_state.dart';

class CompleteRegistration extends StatelessWidget {
  const CompleteRegistration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegisterCubit cubit = RegisterCubit.getInstance(context);
    const Color subColor = Colors.pink;

    return LoginBackground(
      body: Column(
        children: [
          const Text(
            "COMPLETE REGISTRATION",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: MainColors.appColorDark,
              fontFamily: FontFamily.handWriting
            ),
          ),

          const SizedBox(height: 20),

          BlocBuilder<RegisterCubit, RegisterState>(
            buildWhen: (ps, cs) => cs.updateMarketplaceLogo,
            builder: (context, state) {
              return UploadImage(
                imageFile: cubit.marketplaceLogo,
                color: subColor,
                onUploadImage: cubit.uploadImage
              );
            }
          ),

          const Padding(
            padding: EdgeInsets.only(top: 5, bottom: 10),
            child: Text(
              "Upload your marketplace logo",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: MainColors.appColorDark
              ),
            ),
          ),

          CustomTextField(
            controller: cubit.marketplaceController,
            hint: "Marketplace name",
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            prefix: const ImageIcon(AssetImage(AssetImages.miniMarketplace)),
          ),

          BlocBuilder<RegisterCubit, RegisterState>(
            buildWhen: (ps, cs) => cs.updateComRegisterLoading,
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
                onPressed: () => cubit.completeRegister(context),
              );
            }
          ),
        ],
      ),
    );
  }
}

