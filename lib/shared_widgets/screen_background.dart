
import 'package:flutter/material.dart';
import 'package:zk_note/shared/font_family.dart';
import 'package:zk_note/shared/main_colors.dart';

class ScreenBackground extends StatelessWidget {
  final String title;
  final Color appBarColor;
  final bool addBackIcon;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? action;
  final bool Function()? onBackIconPressed;

  const ScreenBackground({
    Key? key,
    this.title = "",
    this.appBarColor = Colors.blue,
    this.action,
    this.addBackIcon = true,
    this.body,
    this.floatingActionButton,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MainColors.appColorDark,
                  MainColors.appColorDark,
                  appBarColor
                ]
              )
            ),

            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  height: 50,
                  child: addBackIcon? IconButton(
                    onPressed: () {
                      if (onBackIconPressed != null) {
                        bool result = onBackIconPressed!();
                        if (result) Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white)
                  ): null,
                ),

                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Colors.white,
                      fontFamily: FontFamily.handWriting
                    ),
                  ),
                ),

                SizedBox(width: 70, child: action),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 65 + safeAreaHeight),
            padding: const EdgeInsets.only(top: 10),
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
          )
        ],
      ),

      floatingActionButton: floatingActionButton,
    );
  }
}


