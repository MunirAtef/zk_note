
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zk_note/firebase/firestore.dart';
import 'package:zk_note/firebase/storage.dart';
import 'package:zk_note/general/city_handler.dart';
import 'package:zk_note/models/city_model.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/governorate_model.dart';
import 'package:zk_note/screens/add_client/add_client_states.dart';
import 'package:zk_note/screens/categories/categories_cubit.dart';
import 'package:zk_note/screens/clients_list/clients_list_cubit.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/pick_image.dart';
import 'package:zk_note/shared_widgets/custom_snake_bar.dart';
import 'package:zk_note/shared_widgets/input_dialog.dart';

import '../../models/trans_payments_model.dart';
import '../../shared/shared_functions.dart';


class AddClientCubit extends Cubit<AddClientState> {
  AddClientCubit() : super(AddClientState());

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  File? selectedImage;
  GovernorateModel? selectedGovernorate;
  CityModel? selectedCity;
  int? selectedCategory;
  String? clientType;
  Set<int> selectedCategories = {};
  bool isLoading = false;

  Set<String> phones = {};
  final List<String> clientTypes = const ["Client", "Supplier"];
  List<CityModel> cities = [];


  void uploadImage(BuildContext context) async {
    File? pickedImage = await PickImage.pickImage(
      context: context,
      color: MainColors.addClientPage,
      onDelete: selectedImage == null? null: () {
        selectedImage = null;
        emit(AddClientState(updateImage: true));
        Navigator.pop(context);
      }
    );

    if (pickedImage != null) {
      selectedImage = pickedImage;
      emit(AddClientState(updateImage: true));
    }
  }

  void updateClientType(String? newType) {
    clientType = newType;
    emit(AddClientState(updateClientType: true));
  }

  void updateGovernorate(GovernorateModel? newGovernorate) async {
    selectedGovernorate = newGovernorate;
    selectedCity = null;
    if (newGovernorate != null && newGovernorate.id != "") {
      cities = await CityHandler.getCities(newGovernorate.id);
    } else {
      selectedGovernorate = null;
    }
    emit(AddClientState(updateGovernorate: true, updateCity: true));
  }

  void updateCity(CityModel? newCity) {
    selectedCity = newCity;
    emit(AddClientState(updateCity: true));
  }

  void addPhoneNumber() {
    String phone = phoneController.text.replaceAll(" ", "");
    phoneController.clear();
    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: "No phone number entered");
      return;
    }
    phones.add(phone);
    emit(AddClientState(updatePhoneList: true));
  }

  void deletePhoneNumber(String phone) {
    phones.remove(phone);
    emit(AddClientState(updatePhoneList: true));
  }

  void updateCategory(int? newCategory) {
    selectedCategory = newCategory;
    emit(AddClientState(updateCategory: true));
  }

  void addCategory() {
    selectedCategories.add(selectedCategory!);
    selectedCategory = null;
    emit(AddClientState(updateCategory: true));
  }

  void deleteCategory(int category) {
    selectedCategories.remove(category);
    emit(AddClientState(updateCategory: true));
  }

  void reset() {
    nameController.clear();
    addressController.clear();
    phoneController.clear();
    phones.clear();
    selectedCategories.clear();
    cities.clear();
    selectedImage = null;
    selectedCategory = null;
    clientType = null;
    selectedGovernorate = null;
    selectedCity = null;
    isLoading = false;
  }

  void addClient(BuildContext context) async {
    String name = nameController.text.trim();
    String? address = addressController.text.trim();
    if (address.isEmpty) address = null;

    if (name.isEmpty) {
      Fluttertoast.showToast(msg: "Client name is required");
      return;
    }
    if (clientType == null) {
      Fluttertoast.showToast(msg: "Select client first");
      return;
    }

    if (!Shared.isConnected(true)) return;
    FocusScope.of(context).unfocus();

    ClientsListCubit clientsListCubit = BlocProvider.of<ClientsListCubit>(context);
    CustomSnackBar csb = CustomSnackBar(
      context: context,
      subColor: MainColors.addClientPage
    );
    isLoading = true;
    emit(AddClientState(updateLoading: true));

    String clientId = Firestore.getId();

    String? imageExt = selectedImage?.path.split(".").last;

    String? imageUrl = await Storage.uploadFile(
      path: StoragePaths.client(clientId, "image.$imageExt"),
      file: selectedImage
    );

    ClientModel client = ClientModel(
      id: clientId,
      name: name,
      isSupplier: clientType == clientTypes[1],
      imageUrl: imageUrl,
      address: address,
      governorate: selectedGovernorate,
      city: selectedCity,
      transPayments: TransPaymentsModel(),
      phones: phones.toList(),
      categories: selectedCategories.toList()
    );

    bool result = await Firestore.uploadClientDoc(client);


    if (!result) {
      isLoading = false;
      emit(AddClientState(updateLoading: true));
      return;
    }

    csb.show("Client added successfully");
    reset();
    clientsListCubit.addClient(client);
    emit(AddClientState.setTrue());
  }


  void createNewCategory(BuildContext context) {
    CategoriesCubit categoriesCubit = BlocProvider.of<CategoriesCubit>(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InputDialog(
          title: "CREATE NEW CATEGORY",
          hint: "Category name",
          prefix: const Icon(Icons.category, size: 24),
          color: MainColors.addClientPage,
          onConfirm: (String category) async {
            int? result = await categoriesCubit.createNewCategory(category);
            if (result != null) {
              selectedCategories.add(result);
              emit(AddClientState(updateCategory: true));
              return true;
            }
            return false;
          },
        );
      }
    );
  }
}





