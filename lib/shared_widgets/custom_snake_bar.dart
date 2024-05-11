
import 'package:flutter/material.dart';

import '../shared/main_colors.dart';

class CustomSnackBar {
  final BuildContext context;
  final Color subColor;
  final Color mainColor;

  CustomSnackBar({
    required this.context,
    this.subColor = MainColors.appColorLight,
    this.mainColor = MainColors.appColorDark
  });

  void show(String message) {
    SnackBar snackBar = SnackBar(
      padding: const EdgeInsets.all(5),
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [mainColor, subColor]),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10)
          )
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15
          )
        ),
      )
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

