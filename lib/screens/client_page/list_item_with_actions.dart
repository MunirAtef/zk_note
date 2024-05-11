


import 'package:flutter/material.dart';
import 'package:zk_note/shared/main_colors.dart';

class ListItemWithActions extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  const ListItemWithActions({
    Key? key,
    required this.title,
    this.actions
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: const BoxDecoration(
        color: MainColors.clientPage,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MainColors.appColorDark,
            MainColors.clientPage
          ]
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomRight: Radius.circular(15)
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                overflow: TextOverflow.ellipsis
              )
            ),
          ),

          ...?actions
        ],
      ),
    );
  }
}


