
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/trans_payments_model.dart';
import 'package:zk_note/screens/clients_list/clients_list_cubit.dart';
import 'package:zk_note/shared/shared_functions.dart';

import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(): super(StatisticsState());

  static StatisticsCubit getInstance(BuildContext context) =>
    BlocProvider.of<StatisticsCubit>(context);

  double purchases = 0;
  double sales = 0;
  double returnToSuppliers = 0;
  double returnFromClients = 0;

  double paymentsToSuppliers = 0;
  double paymentsFromSuppliers = 0;
  double paymentsToClients = 0;
  double paymentsFromClients = 0;

  void calcTotalAmounts(BuildContext context) {
    purchases = 0;
    sales = 0;
    returnToSuppliers = 0;
    returnFromClients = 0;

    paymentsToSuppliers = 0;
    paymentsFromSuppliers = 0;
    paymentsToClients = 0;
    paymentsFromClients = 0;

    List<ClientModel>? clients = ClientsListCubit.getInstance(context).clientModels;
    if (clients == null) return;

    for (ClientModel client in clients) {
      TransPaymentsModel tpm = client.transPayments;

      if (client.isSupplier) {
        purchases += tpm.totalNorTrans;
        returnToSuppliers += tpm.totalRetTrans;
        paymentsToSuppliers += tpm.totalNorPay;
        paymentsFromSuppliers += tpm.totalRetPay;
      } else {
        sales += tpm.totalNorTrans;
        returnFromClients += tpm.totalRetTrans;
        paymentsFromClients += tpm.totalNorPay;
        paymentsToClients += tpm.totalRetPay;
      }
    }
  }

  Map<String, String> invoicesData() => {
    "Purchases": Shared.getPrice(purchases),
    "Sales": Shared.getPrice(sales),

    "Return (suppliers)": Shared.getPrice(returnToSuppliers),
    "Return (clients)": Shared.getPrice(returnFromClients)
  };

  Map<String, String> paymentsData() => {
    "To suppliers": Shared.getPrice(paymentsToSuppliers),
    "From clients": Shared.getPrice(paymentsFromClients),

    "From suppliers": Shared.getPrice(paymentsFromSuppliers),
    "To clients": Shared.getPrice(paymentsToClients),
  };

  String amountOwed() {
    // double priceToMe = sales - purchases + returnToSuppliers - returnFromClients
    //   + paymentsToSuppliers - paymentsFromSuppliers + paymentsFromClients
    //   - paymentsToClients;

    double totalInvoices = sales - purchases + returnToSuppliers - returnFromClients;
    double totalPayments = paymentsToSuppliers - paymentsFromSuppliers - paymentsFromClients
      + paymentsToClients;

    double priceToMe = totalInvoices + totalPayments;

    if (priceToMe > 0) {
      return "Amount owed to you ${Shared.getPrice(priceToMe)}";
    } else if (priceToMe < 0) {
      return "Amount owed on you ${Shared.getPrice(-priceToMe)}";
    }

    return "No amount owed";
  }
}
