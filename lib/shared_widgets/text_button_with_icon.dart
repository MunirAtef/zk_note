
import 'package:flutter/material.dart';

import '../shared/main_colors.dart';

class TextButtonWithIcon extends StatelessWidget {
  final String text;
  final Icon? icon;
  final double size;
  final Color subColor;
  final void Function()? onPressed;

  const TextButtonWithIcon({
    Key? key,
    required this.text,
    this.icon,
    this.size = 16,
    this.subColor = MainColors.appColorDark,
    this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: subColor,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: size
        )
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) icon!,
          if (icon != null) const SizedBox(width: 10),
          Text(text)
        ],
      )
    );
  }
}


