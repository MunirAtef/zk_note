
import 'package:flutter/material.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:auto_direction/auto_direction.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final EdgeInsets? margin;
  final double minHeight;
  final double maxHeight;
  final String hint;
  final int maxLines;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final BorderRadius? borderRadius;
  final bool isReadOnly;
  final bool autoFocus;
  final bool hideText;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    this.controller,
    this.margin,
    this.minHeight = 60,
    this.maxHeight = 60,
    this.hint = "",
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.borderRadius,
    this.isReadOnly = false,
    this.autoFocus = false,
    this.hideText = false,
    this.keyboardType,
    this.onChanged
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      constraints: BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight
      ),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(10)),

        boxShadow: [
          BoxShadow(
            color: Colors.grey[700]!
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 12,
            spreadRadius: -2
          ),
        ]
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, Function(Function()) setInternalState) {
          return AutoDirection(
            text: controller?.text ?? "",
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: maxLines == 1? TextInputAction.done: TextInputAction.newline,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isReadOnly? Colors.red[700] : Colors.grey[800]
              ),
              textAlignVertical: TextAlignVertical(y: maxHeight < 53? 1: 0.6),
              minLines: 1,
              maxLines: maxLines,
              readOnly: isReadOnly,
              autofocus: autoFocus,
              obscureText: hideText,
              onChanged: (String text) {
                setInternalState(() {});
                if (onChanged != null) onChanged!(text);
              },

              decoration: InputDecoration(
                suffixIcon: suffix,
                prefixIcon: prefix,
                prefixIconConstraints: const BoxConstraints(
                  minHeight: 24,
                  minWidth: 40
                ),

                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  backgroundColor: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600
                ),
                border: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(10)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(10),
                  borderSide: const BorderSide(color: MainColors.appColorLight, width: 2)
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

