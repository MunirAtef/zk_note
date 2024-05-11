
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';

import '../../shared/shared_functions.dart';


class AddCategoriesDialog extends StatefulWidget {
  final Future<void> Function(List<int>) onConfirm;
  final List<int> includedCategories;

  const AddCategoriesDialog({
    Key? key,
    required this.includedCategories,
    required this.onConfirm
  }) : super(key: key);

  @override
  State<AddCategoriesDialog> createState() => _AddCategoriesDialogState();
}

class _AddCategoriesDialogState extends State<AddCategoriesDialog> {
  bool isLoading = false;
  List<int> checkedCategories = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async { return !isLoading; },

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
              const Text(
                "ADD CATEGORIES",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 19
                ),
              ),

              const SizedBox(height: 10),

              Container(
                constraints: const BoxConstraints(
                  maxHeight: 250
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      for (int id in widget.includedCategories) Row(
                        children: [
                          Expanded(
                            child: Text(
                              UserData.categoriesMap[id].toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis
                              )
                            ),
                          ),

                          StatefulBuilder(
                            builder: (context, setInnerState) {
                              return Checkbox(
                                value: checkedCategories.contains(id),
                                activeColor: MainColors.clientPage,
                                onChanged: (bool? value) {
                                  value == true? checkedCategories.add(id)
                                    : checkedCategories.remove(id);
                                  setInnerState(() {});
                                }
                              );
                            }
                          ),
                        ],
                      ),

                      StatefulBuilder(
                        builder: (context, setInnerState) {
                          return CustomButton(
                            text: "CONFIRM",
                            color: MainColors.clientPage,
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            isLoading: isLoading,
                            onPressed: () async {
                              if (!Shared.isConnected(true)) return;
                              NavigatorState navigator = Navigator.of(context);
                              if (checkedCategories.isEmpty) {
                                Fluttertoast.showToast(msg: "No category selected");
                                return;
                              }

                              setInnerState(() { isLoading = true; });
                              await widget.onConfirm(checkedCategories);
                              navigator.pop();
                            }
                          );
                        }
                      )
                    ]
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}
