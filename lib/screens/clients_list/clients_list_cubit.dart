
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/firebase/firestore.dart';
import 'package:zk_note/general/city_handler.dart';
import 'package:zk_note/models/city_model.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/governorate_model.dart';
import 'package:zk_note/screens/clients_list/clients_list_state.dart';
import 'package:zk_note/shared/user_data.dart';


class ClientTypes {
  static const String all = "All";
  static const String client = "Client";
  static const String supplier = "Supplier";
}

class ClientsListCubit extends Cubit<ClientsListState> {
  ClientsListCubit(): super(ClientsListState());

  static ClientsListCubit getInstance(BuildContext context) =>
    BlocProvider.of<ClientsListCubit>(context);

  GovernorateModel? selectedGovernorate;
  CityModel? selectedCity;
  String? selectedClientType;
  int? selectedCategory;

  bool isSearchExpanded = false;
  TextEditingController searchController = TextEditingController();

  final List<String> clientTypes = const [
    ClientTypes.all,
    ClientTypes.client,
    ClientTypes.supplier
  ];

  List<GovernorateModel> governorates = [GovernorateModel(), ...CityHandler.governorates];
  List<CityModel>? cities;

  List<int> categories = [-1, ...UserData.categoriesKey];

  List<ClientModel>? clientModels;
  Map<String, bool> visibility = {};


  Future<void> getAllClients() async {
    clientModels ??= await Firestore.getAllClients();
    setVisibility();
    emit(ClientsListState(updateList: true));
  }

  void expandOrCollapseSearch(BuildContext context) {
    isSearchExpanded = !isSearchExpanded;
    if (!isSearchExpanded) {
      searchController.clear();
      onSearch();
      FocusScope.of(context).unfocus();
    }
    emit(ClientsListState(updateSearchState: true));
  }

  void updateClientsList() {
    emit(ClientsListState(updateList: true));
  }

  void setVisibility() {
    for (ClientModel client in clientModels ?? []) {
      visibility[client.id] = showHim(client);
    }
  }

  void addClient(ClientModel client) {
    clientModels?.add(client);
    visibility[client.id] = showHim(client);
    emit(ClientsListState(updateList: true));
  }

  bool showHim(ClientModel client) {
    String searchWord = searchController.text.trim().toLowerCase();
    if (searchWord.isNotEmpty) {
      if (!client.name.toLowerCase().contains(searchWord)) return false;
    }

    if (client.isSupplier && selectedClientType == ClientTypes.client) return false;
    if (!client.isSupplier && selectedClientType == ClientTypes.supplier) return false;

    if (selectedCategory != null && !client.categories.contains(selectedCategory)) return false;

    if (selectedGovernorate != null) {
      if (selectedGovernorate?.id != client.governorate?.id) return false;
      if (selectedCity != null && selectedCity?.id != client.city?.id) return false;
    }

    return true;
  }

  void onSearch() {
    setVisibility();
    emit(ClientsListState(updateList: true));
  }

  void updateClientType(String? newType) {
    selectedClientType = newType == "All"? null: newType;
    setVisibility();
    emit(ClientsListState(updateClientType: true, updateList: true));
  }

  void updateCategory(int? newCategory) {
    selectedCategory = newCategory == -1? null: newCategory;
    setVisibility();
    emit(ClientsListState(updateCategory: true, updateList: true));
  }

  void updateGovernorate(GovernorateModel? newGovernorate) async {
    selectedGovernorate = newGovernorate?.name == "All"? null: newGovernorate;
    selectedCity = null;
    if (newGovernorate != null && newGovernorate.id != "") {
      cities = await CityHandler.getCities(newGovernorate.id);
      cities?.insert(0, CityModel());
    }

    setVisibility();
    emit(ClientsListState(updateGovernorate: true, updateCity: true, updateList: true));
  }

  void updateCity(CityModel? newCity) {
    selectedCity = newCity?.name == "All"? null: newCity;
    setVisibility();
    emit(ClientsListState(updateCity: true, updateList: true));
  }

  String categoryListToString(List<String> categories) {
    String categoryString = "";
    for (String category in categories) {
      categoryString += " <$category> ";
    }

    return categoryString;
  }
}

