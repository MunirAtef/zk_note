
import 'package:flutter/material.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/shared_functions.dart';

class DatePicker extends StatelessWidget {
  final String dateTitle;
  final int dateTime;
  final Color subColor;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double size;
  final void Function(int) onChange;

  const DatePicker({
    Key? key,
    required this.dateTime,
    this.dateTitle = "Date",
    this.subColor = MainColors.appColorLight,
    this.margin = const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    this.size = 18,
    required this.onChange
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,

      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        gradient: LinearGradient(
          colors: [
            MainColors.appColorDark,
            subColor
          ]
        )
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            "$dateTitle: ${Shared.getDate(dateTime)}",
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w600,
              color: Colors.white
            ),
          ),

          TextButton(
            onPressed: () async {
              final int? picked = (await showDatePicker(
                context: context,
                initialDate: DateTime.fromMillisecondsSinceEpoch(dateTime),
                firstDate: DateTime(2015, 8),
                lastDate: DateTime(2101)
              ))?.millisecondsSinceEpoch;

              if (picked != null && picked != dateTime) {
                onChange(picked);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: size)
            ),
            child: Row(
              children: [
                Icon(Icons.date_range, size: size + 8),
                const SizedBox(width: 5),
                const Text("CHANGE")
              ],
            ),
          ),
        ],
      ),
    );
  }
}

