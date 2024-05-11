
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/screens/splash/splash_cubit.dart';
import 'package:zk_note/shared/font_family.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';

import '../../shared/assets.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashCubit? cubit;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    cubit ??= BlocProvider.of<SplashCubit>(context)..init(context);

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MainColors.appColorDark,
              MainColors.addClientPage,
              MainColors.clientsListPage
            ]
          )
        ),
        child: Column(
          children: [
            SizedBox(height: height / 7, width: double.infinity),

            CustomContainer(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(15),
              shadowColor: Colors.grey[600]!,
              child: Image.asset(AssetImages.appIcon),
            ),

            const SizedBox(height: 20),

            const Text(
              "ZK",
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontFamily: FontFamily.princetown
              )
            ),

            const SizedBox(height: 10),

            const Text(
              "invoicement",
              style: TextStyle(
                fontSize: 35,
                color: Colors.white,
                fontFamily: FontFamily.princetown
              )
            ),

            const Spacer(),

            const Text(
              "DEVELOPED BY",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),
            ),

            const SizedBox(height: 10),

            BlocBuilder<SplashCubit, int>(
              builder: (context, state) {
                return Text(
                  cubit!.devName.substring(0, state),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.yellowAccent,
                    fontFamily: FontFamily.handWriting
                  ),
                );
              }
            ),

            const SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}

