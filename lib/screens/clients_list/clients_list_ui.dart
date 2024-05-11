
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/models/city_model.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/governorate_model.dart';
import 'package:zk_note/screens/clients_list/client_card.dart';
import 'package:zk_note/screens/clients_list/clients_list_background.dart';
import 'package:zk_note/screens/clients_list/clients_list_cubit.dart';
import 'package:zk_note/screens/clients_list/clients_list_state.dart';
import 'package:zk_note/shared/assets.dart';
import 'package:zk_note/shared/font_family.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/loading.dart';

import '../../shared_widgets/custom_text_field.dart';

class ClientsList extends StatelessWidget {
  const ClientsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ClientsListCubit cubit = ClientsListCubit.getInstance(context);
    cubit.getAllClients();
    ClientCard.cubit = cubit;
    const Color subColor = MainColors.clientsListPage;
    double screenWidth = MediaQuery.of(context).size.width;

    return ClientsListBackground(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(7, 0, 7, 8),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: const BoxDecoration(
              color: Color(0xFFCCCCCC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25)
              ),
            ),

            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      const SizedBox(width: 5),

                      BlocBuilder<ClientsListCubit, ClientsListState>(
                        buildWhen: (ps, cs) => cs.updateSearchState,
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: () => cubit.expandOrCollapseSearch(context),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: const Color.fromRGBO(80, 0, 0, 1),
                              minimumSize: const Size(45, 35),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              )
                            ),
                            child: Icon(cubit.isSearchExpanded? Icons.cancel: Icons.search)
                          );
                        }
                      ),

                      const SizedBox(width: 5),

                      /// Type filter
                      BlocBuilder<ClientsListCubit, ClientsListState>(
                        buildWhen: (prevState, currentState) => currentState.updateClientType,
                        builder: (context, state) => FilterDropDownMenu(
                          title: "Type",
                          placeholder: "All",
                          items: cubit.clientTypes.map<DropdownMenuItem>((value) {
                            return DropdownMenuItem(value: value, child: Text(value));
                          }).toList(),
                          selectedItem: cubit.selectedClientType,
                          onChange: (newValue) =>
                            cubit.updateClientType(newValue as String?),
                        ),
                      ),

                      /// Category filter
                      BlocBuilder<ClientsListCubit, ClientsListState>(
                        buildWhen: (prevState, currentState) => currentState.updateCategory,
                        builder: (context, state) => FilterDropDownMenu(
                          title: "Category",
                          placeholder: "All",
                          items: cubit.categories.map<DropdownMenuItem>((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(UserData.categoriesMap[value] ?? "All")
                            );
                          }).toList(),
                          selectedItem: cubit.selectedCategory,
                          onChange: (newValue) =>
                            cubit.updateCategory(newValue as int?),
                        ),
                      ),

                      /// Governorate filter
                      BlocBuilder<ClientsListCubit, ClientsListState>(
                        buildWhen: (prevState, currentState) => currentState.updateGovernorate,
                        builder: (context, state) => FilterDropDownMenu(
                          title: "Governorate",
                          placeholder: "All",
                          items: cubit.governorates.map<DropdownMenuItem>((value) {
                            return DropdownMenuItem(value: value, child: Text(value.name));
                          }).toList(),
                          selectedItem: cubit.selectedGovernorate,
                          onChange: (newValue) =>
                            cubit.updateGovernorate(newValue as GovernorateModel?),
                        ),
                      ),

                      /// City filter
                      BlocBuilder<ClientsListCubit, ClientsListState>(
                        buildWhen: (prevState, currentState) => currentState.updateCity,
                        builder: (context, state) {
                          if (cubit.selectedGovernorate == null || cubit.selectedGovernorate?.id == "") {
                            return const SizedBox();
                          }

                          return FilterDropDownMenu(
                            title: "City",
                            placeholder: "All",
                            items: cubit.cities?.map<DropdownMenuItem>((value) {
                              return DropdownMenuItem(value: value, child: Text(value.name));
                            }).toList() ?? [],
                            selectedItem: cubit.selectedCity,
                            onChange: (newValue) =>
                              cubit.updateCity(newValue as CityModel?)
                          );
                        }
                      ),
                    ],
                  ),
                ),


                BlocBuilder<ClientsListCubit, ClientsListState>(
                  buildWhen: (ps, cs) => cs.updateSearchState,
                  builder: (context, state) {
                    bool isExpanded = cubit.isSearchExpanded;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: isExpanded? 65: 0,
                      width: isExpanded? screenWidth: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isExpanded? 1: 0,
                        child: CustomTextField(
                          controller: cubit.searchController,
                          margin: const EdgeInsets.only(top: 5, bottom: 10),
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          minHeight: 50,
                          maxHeight: 50,
                          keyboardType: isExpanded? TextInputType.text: TextInputType.none,
                          autoFocus: false,
                          prefix: isExpanded? const Icon(Icons.search): null,
                          suffix: IconButton(
                            onPressed: cubit.onSearch,
                            icon: const Icon(Icons.done)
                          ),
                          hint: isExpanded? "Search...": "",
                        ),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),

          /// List Body
          BlocBuilder<ClientsListCubit, ClientsListState>(
            buildWhen: (prevState, currentState) => currentState.updateList,
            builder: (context, state) {
              /// Loading
              if (cubit.clientModels == null) {
                return const Expanded(
                  child: Loading(subColor: subColor)
                );
              }

              List<ClientModel> clients = cubit.clientModels ?? [];

              /// Empty list indicator
              if (!cubit.visibility.containsValue(true)) {
                return Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(AssetImages.noResult, width: 180),
                        ),

                        const Text(
                          "No result found",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: subColor,
                            fontFamily: FontFamily.handWriting
                          ),
                        ),

                        const SizedBox(height: 30)
                      ],
                    ),
                  ),
                );
              }

              /// List
              return Expanded(
                child: ListView.builder(
                  itemCount: clients.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (BuildContext context, int index) {
                    ClientModel client = clients[index];
                    return Visibility(
                      visible: cubit.visibility[client.id] == true,
                      child: ClientCard(clientModel: client)
                    );
                  },
                )
              );
            }
          ),
        ],
      ),
    );
  }
}


class FilterDropDownMenu extends StatelessWidget {
  final String title;
  final String placeholder;
  final dynamic selectedItem;
  final List<DropdownMenuItem> items;
  final void Function(dynamic)? onChange;

  const FilterDropDownMenu({
    Key? key,
    required this.title,
    required this.placeholder,
    required this.items,
    this.selectedItem,
    this.onChange
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: const BoxDecoration(
            color: Color.fromRGBO(80, 0, 0, 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10)
            )
          ),

          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),
            ),
          ),
        ),

        Container(
          width: 150,
          height: 35,
          margin: const EdgeInsets.fromLTRB(0, 5, 5, 5),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10)
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MainColors.appColorDark,
                Colors.red
              ]
            )
          ),

          child: DropdownButton(
            value: selectedItem,
            dropdownColor: const Color.fromRGBO(0, 0, 100, 1),
            hint: Text(
              placeholder,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400]
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              overflow: TextOverflow.ellipsis
            ),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, size: 24, color: Colors.white),
            onChanged: onChange,
            items: items
          ),
        ),
      ],
    );
  }
}

