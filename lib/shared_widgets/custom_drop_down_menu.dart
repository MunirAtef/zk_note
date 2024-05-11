
import 'package:flutter/material.dart';
import 'package:zk_note/shared/main_colors.dart';

class CustomDropDownMenu extends StatelessWidget {
  final String hintText;
  final String placeholder;
  final String? selectedItem;
  final Color subColor;
  final List<String> items;
  final EdgeInsets margin;
  final double widthForHint;
  final void Function(String?)? onChange;

  const CustomDropDownMenu({
    Key? key,
    required this.hintText,
    required this.placeholder,
    required this.items,
    this.subColor = Colors.blue,
    this.selectedItem,
    this.margin = const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    this.widthForHint = 110,
    this.onChange
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Row(
        children: [
          Container(
            width: widthForHint,
            height: 50,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 20, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10)
              )
            ),
            child: Center(
              child: Text(
                hintText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              // margin: const EdgeInsets.fromLTRB(0, 10, 30, 10),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10)
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MainColors.appColorDark,
                    subColor
                  ]
                )
              ),

              child: DropdownButton<String>(
                value: selectedItem,
                dropdownColor: MainColors.appColorDark,
                hint: Text(
                  placeholder,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400]
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, size: 30, color: Colors.white),
                onChanged: onChange,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class CustomDropDownMenuForObj extends StatelessWidget {
  final String hintText;
  final String placeholder;
  final dynamic selectedItem;
  final Color subColor;
  final EdgeInsets margin;
  final List<DropdownMenuItem<dynamic>>? items;
  final void Function(dynamic)? onChange;

  const CustomDropDownMenuForObj({
    Key? key,
    required this.hintText,
    required this.placeholder,
    required this.items,
    this.selectedItem,
    this.margin = const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    this.subColor = Colors.blue,
    this.onChange
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Row(
        children: [
          Container(
            width: 110,
            height: 50,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 20, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10)
              )
            ),
            child: Center(
              child: Text(
                hintText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10)
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MainColors.appColorDark,
                    subColor
                  ]
                )
              ),

              child: DropdownButton<dynamic>(
                value: selectedItem,
                dropdownColor: MainColors.appColorDark,
                hint: Text(
                  placeholder,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400]
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, size: 30, color: Colors.white),
                onChanged: onChange,
                items: items,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

