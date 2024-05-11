
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zk_note/firebase/firestore.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/screens/add_client/add_client_cubit.dart';
import 'package:zk_note/screens/categories/categories_state.dart';
import 'package:zk_note/screens/clients_list/clients_list_cubit.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/confirm_dialog.dart';
import 'package:zk_note/shared_widgets/input_dialog.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(): super(CategoriesState());


  Future<int?> createNewCategory(String category) async {
    if (category.isEmpty) {
      Fluttertoast.showToast(msg: "No category entered");
      return null;
    }
    if (UserData.categoriesMap.containsValue(category)) {
      Fluttertoast.showToast(msg: "Category already exists");
      return null;
    }

    int newKey = UserData.categoriesKey.isEmpty? 0
      : UserData.categoriesKey.reduce(max) + 1;

    await Firestore.updateCategory(newKey, category);

    UserData.categoriesKey.add(newKey);
    UserData.categoriesMap[newKey] = category;
    emit(CategoriesState(updateList: true));
    return newKey;
  }

  void addCategory(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InputDialog(
          title: "CREATE NEW CATEGORY",
          hint: "Category name",
          prefix: const Icon(Icons.category),
          color: MainColors.categoriesPage,
          onConfirm: (String category) async
            => (await createNewCategory(category)) != null,
        );
      }
    );
  }

  void editCategory(int id, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InputDialog(
          title: "EDIT CATEGORY",
          hint: "New category name",
          defaultText: UserData.categoriesMap[id],
          prefix: const Icon(Icons.category, size: 24),
          color: MainColors.categoriesPage,
          onConfirm: (String category) async {
            String categoryName = category.trim();
            if (categoryName.isEmpty) {
              Fluttertoast.showToast(msg: "No category entered");
              return false;
            }

            await Firestore.updateCategory(id, categoryName);

            UserData.categoriesMap[id] = categoryName;
            emit(CategoriesState(updateList: true));
            return true;
          },
        );
      }
    );
  }

  void deleteCategory(int categoryId, BuildContext context) {
    ClientsListCubit clientsCubit = BlocProvider.of<ClientsListCubit>(context);
    AddClientCubit addClientCubit = BlocProvider.of<AddClientCubit>(context);

    for (ClientModel clientModel in clientsCubit.clientModels ?? []) {
      if (clientModel.categories.contains(categoryId)) {
        Fluttertoast.showToast(msg: "Can't delete used category");
        return;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: "DELETE CATEGORY",
          content: "Are you sure you want to delete ${UserData.categoriesMap[categoryId]} category",
          color: MainColors.categoriesPage,
          onConfirm: () async {
            await Firestore.deleteCategory(categoryId);
            UserData.categoriesMap.remove(categoryId);
            UserData.categoriesKey.remove(categoryId);
            emit(CategoriesState(updateList: true));

            if (addClientCubit.selectedCategory == categoryId) {
              addClientCubit.selectedCategory = null;
            }
            if (addClientCubit.selectedCategories.contains(categoryId)) {
              addClientCubit.selectedCategories.remove(categoryId);
            }
            return true;
          },
        );
      }
    );
  }
}

