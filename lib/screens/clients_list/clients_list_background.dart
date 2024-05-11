
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/screens/home_page/home_page_cubit.dart';
import 'package:zk_note/screens/home_page/home_page_state.dart';

import '../../shared/assets.dart';
import '../../shared/font_family.dart';
import '../../shared/main_colors.dart';
import '../../shared/user_data.dart';


class ClientsListBackground extends StatelessWidget {
  final Widget? body;
  final Widget? action;
  final bool Function()? onBackIconPressed;

  const ClientsListBackground({
    Key? key,
    this.action,
    this.body,
    this.onBackIconPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double safeAreaHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 10 + safeAreaHeight, bottom: 35),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MainColors.appColorDark,
                  MainColors.appColorDark,
                  MainColors.clientsListPage
                ]
              )
            ),

            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: IconButton(
                    onPressed: () => HomePageCubit.getInstance(context)
                      .scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu, color: Colors.white)
                  ),
                ),

                const Expanded(
                  child: Text(
                    "CLIENTS & SUPPLIERS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Colors.white,
                      fontFamily: FontFamily.handWriting
                    ),
                  ),
                ),

                SizedBox(
                  width: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: BlocBuilder<HomePageCubit, HomePageState>(
                      buildWhen: (ps, cs) => cs.updateMpLogo,
                      builder: (context, state) {
                        return ClipOval(
                          child: UserData.mpLogo == null? CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                AssetImages.marketplace,
                                width: 40,
                              ),
                            ),
                          ): CachedNetworkImage(
                            imageUrl: UserData.mpLogo!,
                            placeholder: (context, url) {
                              return Padding(
                                padding: const EdgeInsets.all(5),
                                child: Image.asset(AssetImages.hourglass),
                              );
                            },
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                    ),
                  )
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 65 + safeAreaHeight),
            padding: const EdgeInsets.only(top: 7),
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30)
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[600]!
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 8,
                  spreadRadius: -5
                ),
              ]
            ),

            child: body,
          ),
        ],
      ),
    );
  }
}



