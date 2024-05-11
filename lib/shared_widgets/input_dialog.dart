
import 'package:flutter/material.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';
import 'package:zk_note/shared_widgets/custom_text_field.dart';


class InputDialog extends StatelessWidget {
  final String title;
  final String hint;
  final String? defaultText;
  final bool multiLine;
  final Widget? prefix;
  final Color? color;
  final TextInputType? keyboardType;
  final Future<bool> Function(String)? onConfirm;

  InputDialog({
    super.key,
    required this.title,
    required this.hint,
    this.defaultText,
    this.multiLine = false,
    this.prefix,
    this.color,
    this.keyboardType,
    this.onConfirm
  }) {
    textFieldController = TextEditingController(text: defaultText);
  }

  bool isLoading = false;
  late TextEditingController textFieldController;


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return !isLoading;
      },
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(vertical: 70),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),

        content: CustomContainer(
          width: width - 80,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 19
                ),
              ),

              CustomTextField(
                controller: textFieldController,
                hint: hint,
                prefix: prefix,
                autoFocus: true,
                margin: const EdgeInsets.only(top: 15),
                maxHeight: multiLine? 100 : 60,
                maxLines: multiLine? 3 : 1,
                keyboardType: keyboardType,
              ),

              StatefulBuilder(
                builder: (context, setInternalState) {
                  return CustomButton(
                    text: "CONFIRM",
                    isLoading: isLoading,
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    color: color ?? MainColors.appColorLight,
                    onPressed: () async {
                      if (onConfirm == null) return;
                      NavigatorState navigator = Navigator.of(context);
                      setInternalState(() { isLoading = true; });
                      bool result = await onConfirm!(textFieldController.text.trim());
                      setInternalState(() { isLoading = false; });
                      if (result) navigator.pop();
                    },
                  );
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}



