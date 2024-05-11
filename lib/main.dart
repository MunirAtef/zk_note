import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/screens/future_dues/future_dues_cubit.dart';

import 'screens/add_client/add_client_cubit.dart';
import 'screens/add_payment/add_payment_cubit.dart';
import 'screens/add_transaction/add_transaction_cubit.dart';
import 'screens/categories/categories_cubit.dart';
import 'screens/choose_login_type/choose_login_type_cubit.dart';
import 'screens/client_page/client_page_cubit.dart';
import 'screens/clients_list/clients_list_cubit.dart';
import 'screens/home_page/home_page_cubit.dart';
import 'screens/invoice_details/invoice_details_cubit.dart';
import 'screens/register/register_cubit.dart';
import 'screens/splash/splash_cubit.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/statistics/statistics_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // tz.initializeTimeZones();
  //
  // await Workmanager().initialize(callbackDispatcher);
  // await NotificationService.initNotification();
  //
  // Workmanager().registerPeriodicTask(
  //   "1",
  //   "dailyTask",
  //   frequency: const Duration(minutes: 15),
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => SplashCubit()),
        BlocProvider(create: (BuildContext context) => HomePageCubit()),
        BlocProvider(create: (BuildContext context) => ClientsListCubit()),
        BlocProvider(create: (BuildContext context) => AddClientCubit()),
        BlocProvider(create: (BuildContext context) => CategoriesCubit()),
        // BlocProvider(create: (BuildContext context) => LoginCubit()),
        BlocProvider(create: (BuildContext context) => ClientPageCubit()),
        BlocProvider(create: (BuildContext context) => AddTransactionCubit()),
        BlocProvider(create: (BuildContext context) => InvoiceDetailsCubit()),
        BlocProvider(create: (BuildContext context) => AddPaymentCubit()),
        BlocProvider(create: (BuildContext context) => StatisticsCubit()),
        BlocProvider(create: (BuildContext context) => RegisterCubit()),
        BlocProvider(create: (BuildContext context) => ChooseLoginTypeCubit()),
        BlocProvider(create: (BuildContext context) => FutureDuesCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ZK Financial Note',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
      ),
    );
  }
}
