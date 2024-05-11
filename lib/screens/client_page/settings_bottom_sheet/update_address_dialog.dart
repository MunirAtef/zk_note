
import 'package:flutter/material.dart';
import 'package:zk_note/general/city_handler.dart';
import 'package:zk_note/models/city_model.dart';
import 'package:zk_note/models/governorate_model.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';
import 'package:zk_note/shared_widgets/custom_drop_down_menu.dart';
import 'package:zk_note/shared_widgets/custom_text_field.dart';


class UpdateAddressDialog extends StatelessWidget {
  final String? defaultAddress;
  final Future<void> Function(
    String? addressNote,
    GovernorateModel? governorate,
    CityModel? city
  ) onConfirm;

  UpdateAddressDialog({
    Key? key,
    this.defaultAddress,
    required this.onConfirm
  }) : super(key: key) {
    addressNoteController = TextEditingController(text: defaultAddress);
  }

  bool isLoading = false;
  late TextEditingController addressNoteController;

  List<CityModel> cities = [];
  GovernorateModel? selectedGovernorate;
  CityModel? selectedCity;


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
                "UPDATE CLIENT ADDRESS",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 19
                ),
              ),

              // const SizedBox(height: 10),

              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: addressNoteController,
                      hint: "Address note",
                      prefix: const Icon(Icons.location_city),
                      margin: const EdgeInsets.only(top: 15),
                    ),

                    StatefulBuilder(
                      builder: (context, setInternalState) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomDropDownMenuForObj(
                            hintText: "Governorate",
                            placeholder: "Not specified",
                            subColor: MainColors.clientSettingsPage,
                            // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            margin: const EdgeInsets.only(top: 15),
                            items: CityHandler.governorates.map<DropdownMenuItem>((value) {
                              return DropdownMenuItem(value: value, child: Text(value.name));
                            }).toList(),
                            selectedItem: selectedGovernorate,
                            onChange: (newValue) async {
                              selectedGovernorate = newValue as GovernorateModel?;
                              selectedCity = null;
                              if (selectedGovernorate != null) {
                                cities = await CityHandler.getCities(
                                  selectedGovernorate!.id
                                );
                              }
                              setInternalState(() {});
                            }
                          ),

                          if (selectedGovernorate != null) CustomDropDownMenuForObj(
                            hintText: "City",
                            placeholder: "Not specified",
                            subColor: MainColors.clientSettingsPage,
                            margin: const EdgeInsets.only(top: 15),
                            items: cities.map<DropdownMenuItem>((value) {
                              return DropdownMenuItem(value: value, child: Text(value.name));
                            }).toList(),
                            selectedItem: selectedCity,
                            onChange: (newValue) => setInternalState(() {
                              selectedCity = newValue as CityModel?;
                            }),
                          ),
                        ],
                      ),
                    ),

                    StatefulBuilder(
                      builder: (context, setInnerState) {
                        return CustomButton(
                          text: "CONFIRM",
                          color: MainColors.clientSettingsPage,
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          isLoading: isLoading,
                          onPressed: () async {
                            NavigatorState navigator = Navigator.of(context);
                            setInnerState(() { isLoading = true; });
                            await onConfirm(
                              addressNoteController.text.trim(),
                              selectedGovernorate,
                              selectedCity
                            );
                            navigator.pop();
                          }
                        );
                      }
                    )
                  ]
                ),
              )
            ]
          )
        )
      )
    );
  }
}

