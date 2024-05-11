
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:zk_note/screens/add_client/add_client_ui.dart';
import 'package:zk_note/screens/categories/categories_ui.dart';
import 'package:zk_note/screens/clients_list/clients_list_ui.dart';
import 'package:zk_note/screens/home_page/home_page_cubit.dart';
import 'package:zk_note/screens/home_page/home_page_state.dart';
import 'package:zk_note/screens/statistics/statistics_ui.dart';
import 'package:zk_note/shared/main_colors.dart';

import '../../general/connectivity.dart';
import 'custom_drawer_ui.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomePageCubit cubit = HomePageCubit.getInstance(context);
    ConnectivityCheck.connectivityListener(context);

    final List<Widget> routes = [
      const ClientsList(),
      const AddClient(),
      const Categories(),
      const Statistics(),
    ];

    final List<Color> colors = [
      MainColors.clientsListPage,
      MainColors.addClientPage,
      MainColors.categoriesPage,
      MainColors.statisticsPage
    ];

    return WillPopScope(
      onWillPop: cubit.onWillPop,
      child: BlocBuilder<HomePageCubit, HomePageState>(
        buildWhen: (ps, cs) => cs.updateRoute,
        builder: (context, state) {
          int routeIndex = cubit.routeIndex;

          return Scaffold(
            key: cubit.scaffoldKey,

            body: routes[routeIndex],

            bottomNavigationBar: SnakeNavigationBar.gradient(
              height: 60,
              backgroundGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MainColors.appColorDark,
                  colors[routeIndex]
                ]
              ),

              selectedItemGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MainColors.appColorLight,
                  colors[routeIndex]
                ]
              ),

              unselectedItemGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white,
                ]
              ),

              snakeViewGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white
                ]
              ),

              snakeShape: SnakeShape.circle,

              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12
              ),

              showUnselectedLabels: true,
              showSelectedLabels: true,

              currentIndex: routeIndex,
              onTap: (index) => cubit.updateRoute(index),

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home'
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.person_add_alt_1),
                  label: 'New Client'
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: 'Categories'
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.stacked_bar_chart),
                  label: 'Statistics'
                ),
              ],
            ),

            drawer: const CustomDrawer(),
          );
        }
      ),
    );
  }
}

