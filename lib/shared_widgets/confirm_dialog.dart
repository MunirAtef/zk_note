
import 'package:flutter/material.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';


class ConfirmDialog extends StatefulWidget {
  final String title;
  final String? content;
  final Color? color;
  final Future<bool> Function()? onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.content,
    this.color,
    this.onConfirm
  });

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool isLoading = false;

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
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 19
                ),
              ),

              const SizedBox(height: 10),

              if (widget.content != null) Text(
                widget.content!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600
                ),
              ),

              CustomButton(
                text: "CONFIRM",
                isLoading: isLoading,
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                color: widget.color ?? MainColors.appColorLight,
                onPressed: () async {
                  if (widget.onConfirm == null) return;
                  NavigatorState navigator = Navigator.of(context);
                  setState(() { isLoading = true; });
                  bool result = await widget.onConfirm!();
                  setState(() { isLoading = false; });
                  if (result) navigator.pop();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}



