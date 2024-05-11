
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/general/city_handler.dart';
import 'package:zk_note/models/city_model.dart';
import 'package:zk_note/models/governorate_model.dart';
import 'package:zk_note/screens/add_client/add_client_cubit.dart';
import 'package:zk_note/screens/add_client/add_client_states.dart';
import 'package:zk_note/screens/add_client/phone_list_item.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import 'package:zk_note/shared_widgets/custom_drop_down_menu.dart';
import 'package:zk_note/shared_widgets/custom_text_field.dart';
import 'package:zk_note/shared_widgets/screen_background.dart';
import 'package:zk_note/shared_widgets/upload_image.dart';


class AddClient extends StatelessWidget {
  const AddClient({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AddClientCubit cubit = BlocProvider.of<AddClientCubit>(context);
    const Color subColor = MainColors.addClientPage;

    return ScreenBackground(
      title: "ADD NEW CLIENT",
      appBarColor: subColor,
      addBackIcon: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 10),

        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// Image box
              BlocBuilder<AddClientCubit, AddClientState>(
                buildWhen: (prevState, currentState) => currentState.updateImage,
                builder: (context, AddClientState state) {
                  return UploadImage(
                    imageFile: cubit.selectedImage,
                    color: subColor,
                    onUploadImage: cubit.uploadImage
                  );
                }
              ),

              const SizedBox(height: 10),
              const Divider(thickness: 2),

              CustomTextField(
                controller: cubit.nameController,
                hint: "Client name",
                prefix: const Icon(Icons.person, size: 24),
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),

              CustomTextField(
                controller: cubit.addressController,
                hint: "Address note",
                prefix: const Icon(Icons.location_city, size: 24),
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),

              CustomTextField(
                controller: cubit.phoneController,
                hint: "Add phone number",
                prefix: const Icon(Icons.phone, size: 24),
                suffix: IconButton(
                  onPressed: cubit.addPhoneNumber,
                  icon: const Icon(Icons.add_box_rounded, size: 24)
                ),
                margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                keyboardType: TextInputType.phone,
              ),

              BlocBuilder<AddClientCubit, AddClientState>(
                buildWhen: (prevState, currentState) => currentState.updatePhoneList,
                builder: (context, AddClientState state) => Column(
                  children: [
                    for (String phone in cubit.phones) PhoneListItem(
                      phoneNumber: phone,
                      onDelete: () => cubit.deletePhoneNumber(phone),
                    ),
                  ],
                )
              ),

              const SizedBox(height: 10),
              const Divider(thickness: 2),

              BlocBuilder<AddClientCubit, AddClientState>(
                buildWhen: (prevState, currentState) => currentState.updateClientType,
                builder: (context, AddClientState state) {
                  return CustomDropDownMenu(
                    hintText: "Client type",
                    placeholder: "Select client type",
                    items: cubit.clientTypes,
                    subColor: subColor,
                    selectedItem: cubit.clientType,
                    onChange: (String? newValue) => cubit.updateClientType(newValue),
                  );
                }
              ),

              BlocBuilder<AddClientCubit, AddClientState>(
                buildWhen: (prevState, currentState) => currentState.updateGovernorate,
                builder: (context, AddClientState state) => CustomDropDownMenuForObj(
                  hintText: "Governorate",
                  placeholder: "Select governorate",
                  subColor: subColor,
                  items: CityHandler.governorates.map<DropdownMenuItem>((value) {
                    return DropdownMenuItem<GovernorateModel>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                  selectedItem: cubit.selectedGovernorate,
                  onChange: (newValue) => cubit.updateGovernorate(newValue)
                )
              ),

              BlocBuilder<AddClientCubit, AddClientState>(
                buildWhen: (prevState, currentState) => currentState.updateCity,
                builder: (context, AddClientState state) {
                  if (cubit.selectedGovernorate == null) return const SizedBox();

                  return CustomDropDownMenuForObj(
                    hintText: "City",
                    placeholder: "Select city",
                    subColor: subColor,
                    items: cubit.cities.map<DropdownMenuItem>((value) {
                      return DropdownMenuItem<CityModel>(
                        value: value,
                        child: Text(value.name),
                      );
                    }).toList(),
                    selectedItem: cubit.selectedCity,
                    onChange: (newValue) => cubit.updateCity(newValue)
                  );
                }
              ),

              const Divider(thickness: 2),

              BlocBuilder<AddClientCubit, AddClientState>(
                buildWhen: (prevState, currentState) => currentState.updateCategory,
                builder: (context, AddClientState state) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButton<int>(
                              value: cubit.selectedCategory,
                              dropdownColor: const Color.fromRGBO(255, 255, 255, 1),
                              hint: Text(
                                "Select category",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600]
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(0, 0, 100, 1),
                                overflow: TextOverflow.ellipsis
                              ),
                              isExpanded: true,
                              onChanged: (int? newValue) => cubit.updateCategory(newValue),
                              items: UserData.categoriesKey.map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(UserData.categoriesMap[value].toString()),
                                );
                              }).toList(),
                            ),
                          ),

                          OutlinedButton(
                            onPressed: cubit.selectedCategory == null? null:
                              () => cubit.addCategory(),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color.fromRGBO(0, 0, 100, 1)
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.add_box_rounded),
                                SizedBox(width: 5),
                                Text("ADD")
                              ],
                            )
                          )
                        ],
                      ),
                    ),

                    Column(
                      children: [
                        for (int id in cubit.selectedCategories)
                          PhoneListItem(
                            phoneNumber: UserData.categoriesMap[id].toString(),
                            onDelete: () => cubit.deleteCategory(id),
                          ),

                        TextButton(
                          onPressed: () => cubit.createNewCategory(context),
                          style: TextButton.styleFrom(foregroundColor: subColor),
                          child: const Text(
                            "CREATE NEW CATEGORY",
                            style: TextStyle(fontWeight: FontWeight.w600)
                          ),
                        )
                      ],
                    )
                  ],
                )
              ),

              const Divider(thickness: 2),

              BlocBuilder<AddClientCubit, AddClientState>(
                buildWhen: (prevState, currentState) => currentState.updateLoading,
                builder: (context, AddClientState state) => CustomButton(
                  onPressed: () => cubit.addClient(context),
                  text: "ADD CLIENT",
                  color: subColor,
                  leading: const Icon(Icons.add_box_rounded, color: Colors.white),
                  isLoading: cubit.isLoading,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

