
import 'package:flutter/material.dart';
import 'package:zk_note/shared/main_colors.dart';

class SettingsButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final Icon leading;

  const SettingsButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.leading
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: () => onPressed(),
        style: TextButton.styleFrom(
          foregroundColor: MainColors.clientSettingsPage
        ),
        child: Row(
          children: [
            leading,

            const SizedBox(width: 10),

            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600
              )
            ),
          ],
        )
      ),
    );
  }
}
