
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/screens/categories/categories_cubit.dart';
import 'package:zk_note/screens/categories/categories_state.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import 'package:zk_note/shared_widgets/screen_background.dart';

class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CategoriesCubit cubit = BlocProvider.of<CategoriesCubit>(context);
    CategoryCard.cubit = cubit;
    const Color subColor = MainColors.categoriesPage;

    return ScreenBackground(
      title: "CATEGORIES",
      appBarColor: subColor,
      addBackIcon: false,
      body: Column(
        children: [
          const SizedBox(height: 20),

          Expanded(
            child: BlocBuilder<CategoriesCubit, CategoriesState>(
              buildWhen: (pervState, currentState) => currentState.updateList,
              builder: (context, state) {
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: UserData.categoriesKey.length,
                  itemBuilder: (context, index) {
                    return CategoryCard(categoryId: UserData.categoriesKey[index]);
                  },
                );
              }
            ),
          ),

          CustomButton(
            onPressed: () => cubit.addCategory(context),
            color: subColor,
            text: "CREATE NEW CATEGORY",
            leading: const Icon(Icons.add_box, color: Colors.white),
          )
        ],
      ),
    );
  }
}


class CategoryCard extends StatelessWidget {
  static late CategoriesCubit cubit;
  final int categoryId;
  const CategoryCard({Key? key, required this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MainColors.appColorDark,
            MainColors.categoriesPage
          ]
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomRight: Radius.circular(15)
        )
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              UserData.categoriesMap[categoryId].toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                overflow: TextOverflow.ellipsis
              ),
            ),
          ),

          IconButton(
            onPressed: () => cubit.editCategory(categoryId, context),
            icon: const Icon(Icons.edit, color: Colors.white)
          ),
          IconButton(
            onPressed: () => cubit.deleteCategory(categoryId, context),
            icon: const Icon(Icons.delete, color: Colors.white)
          ),
        ],
      ),
    );
  }
}

