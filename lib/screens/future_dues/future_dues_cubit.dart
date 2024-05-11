
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/models/payment_model.dart';
import 'package:zk_note/screens/clients_list/clients_list_cubit.dart';
import 'package:zk_note/screens/future_dues/future_dues_state.dart';

import '../../firebase/firestore.dart';
import '../../models/client_model.dart';

class FutureDuesCubit extends Cubit<FutureDuesState> {
  FutureDuesCubit(): super(FutureDuesState());

  static FutureDuesCubit getInstance(BuildContext context) =>
    BlocProvider.of<FutureDuesCubit>(context);

  List<PaymentModel>? notifications;

  String? selectedFlow;
  List<String> flows = ["All", "Inbound", "Outbound"];

  Future<void> setInitial() async {
    notifications = null;
    notifications = await Firestore.getFutureDues();
    notifications?.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    emit(FutureDuesState());

    // await LocalNotification.initialize();
  }

  void onFlowChange(String? newFlow) {
    selectedFlow = newFlow;
    emit(FutureDuesState());
  }

  ClientModel getUserById(BuildContext context, String id) {
    List<ClientModel> clients = ClientsListCubit.getInstance(context).clientModels ?? [];

    return clients.firstWhere((client) => client.id == id);
  }
}
