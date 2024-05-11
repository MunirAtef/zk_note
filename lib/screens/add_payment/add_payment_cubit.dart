
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zk_note/firebase/firestore.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/payment_model.dart';
import 'package:zk_note/screens/add_payment/add_payment_state.dart';
import 'package:zk_note/screens/client_page/client_page_cubit.dart';
import 'package:zk_note/shared/invoice_data.dart';
import 'package:zk_note/shared/shared_functions.dart';
import 'package:zk_note/shared_widgets/custom_snake_bar.dart';

import '../../shared/main_colors.dart';

class AddPaymentCubit extends Cubit<AddPaymentState> {
  AddPaymentCubit(): super(AddPaymentState());

  static AddPaymentCubit getInstance(BuildContext context) =>
    BlocProvider.of<AddPaymentCubit>(context);

  void setInitial(bool isSupplier) {
    paymentDate = DateTime.now().millisecondsSinceEpoch;
    dueDateForCheck = DateTime.now().millisecondsSinceEpoch;

    this.isSupplier = isSupplier;
    isOutbound = isSupplier;

    currentFlow = isOutbound? "OUTBOUND PAYMENT": "INBOUND PAYMENT";
    anotherFlow = isOutbound? "INBOUND PAYMENT": "OUTBOUND PAYMENT";

    maxDayNotify = 0;
    notifyBefore = 0;
    notifyMe = true;
  }

  late bool isSupplier;
  late int paymentDate;
  late int dueDateForCheck;

  late bool isOutbound;

  late String currentFlow;
  late String anotherFlow;
  bool showFlowType = false;

  bool isLoading = false;

  int maxDayNotify = 0;
  int notifyBefore = 0;
  bool notifyMe = true;

  List<String> paymentMethods = [
    PaymentMethods.cash,
    PaymentMethods.bankTransfer,
    PaymentMethods.check,
  ];

  String selectedPaymentMethod = PaymentMethods.cash;
  TextEditingController paidAmountController = TextEditingController();

  void expandOrCollapseWhoPaid() {
    showFlowType = !showFlowType;
    emit(AddPaymentState(updateFlowType: true));
  }

  void changeFlowType() {
    isOutbound = !isOutbound;
    showFlowType = false;
    String temp = currentFlow;
    currentFlow = anotherFlow;
    anotherFlow = temp;
    emit(AddPaymentState(updateFlowType: true, updatePaymentMethod: true));
  }

  Future<void> selectInvoiceDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.fromMillisecondsSinceEpoch(paymentDate),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101)
    );

    if (picked != null) {
      paymentDate = picked.millisecondsSinceEpoch;
      emit(AddPaymentState(updateDate: true));
    }
  }

  void onPaymentMethodChanged(String? newPaymentMethod) {
    if (newPaymentMethod != null) {
      selectedPaymentMethod = newPaymentMethod;
      emit(AddPaymentState(updatePaymentMethod: true));
    }
  }

  bool isPaymentByCheck() => selectedPaymentMethod == PaymentMethods.check;

  bool addNotifier() {
    return selectedPaymentMethod == PaymentMethods.check && isOutbound && maxDayNotify >= 1;
  }

  void changeNotifyAfter(bool increase) {
    if (increase) {
      if (notifyBefore == maxDayNotify) return;
      notifyBefore++;
    } else {
      if (notifyBefore == 1) return;
      notifyBefore--;
    }

    emit(AddPaymentState(updatePaymentMethod: true));
  }

  void changeNotifyMe() {
    notifyMe = !notifyMe;
    emit(AddPaymentState(updatePaymentMethod: true));
  }

  void onDateChange(int newDateTime) {
    paymentDate = newDateTime;
    emit(AddPaymentState(updateDate: true));
  }

  void onCheckDueDateChange(int newDateTime) {
    dueDateForCheck = newDateTime;
    int secondsRemaining = dueDateForCheck - DateTime.now().millisecondsSinceEpoch;
    double days = secondsRemaining / 86400000;

    maxDayNotify = days.toInt();
    notifyBefore = maxDayNotify > 5? 5: maxDayNotify;

    emit(AddPaymentState(updatePaymentMethod: true));
  }

  bool clearPage() {
    selectedPaymentMethod = PaymentMethods.cash;
    paidAmountController.clear();
    showFlowType = false;
    isLoading = false;
    return true;
  }

  Future<void> addPayment(BuildContext context, ClientModel clientModel) async {
    String paid = paidAmountController.text.trim();
    double? paidAmount = double.tryParse(paid);
    if (paidAmount == null) {
      Fluttertoast.showToast(msg: "Enter correct paid amount");
      return;
    }

    if (!Shared.isConnected(true)) return;
    FocusScope.of(context).unfocus();

    CustomSnackBar csb = CustomSnackBar(
      context: context,
      subColor: MainColors.paymentsPage
    );

    int? notificationTime;
    if (addNotifier() && notifyMe) {
      notificationTime = dueDateForCheck - notifyBefore * 86400000;
    }

    PaymentModel paymentModel = PaymentModel(
      id: Firestore.getId(),
      clientId: clientModel.id,
      amount: paidAmount,
      paymentMethod: selectedPaymentMethod,
      date: paymentDate,
      dueDate: selectedPaymentMethod == PaymentMethods.check? dueDateForCheck: null,
      notifyAt: notificationTime,
      isNorm: !(isOutbound ^ isSupplier)
    );

    ClientPageCubit clientPageCubit = ClientPageCubit.getInstance(context);
    isLoading = true;
    emit(AddPaymentState(updateLoading: true));
    bool result = await Firestore.uploadPaymentDoc(paymentModel);
    if (!result) {
      isLoading = false;
      emit(AddPaymentState(updateLoading: true));
      return;
    }

    clearPage();
    emit(AddPaymentState.setTrue());

    clientPageCubit.payments?.insert(0, paymentModel);
    clientPageCubit.payments?.sort((a, b) => b.date.compareTo(a.date));

    paymentModel.isNorm?
      clientModel.transPayments.totalNorPay += paidAmount:
      clientModel.transPayments.totalRetPay += paidAmount;

    clientPageCubit.updatePayments();
    csb.show("Payment added successfully");
  }

  
  // Future<void> saveNotification(PaymentModel payment, String clientName) async {
  //   if (payment.notifyAt == null) return;
  //
  //   String notificationBody = "The check of "
  //     "${SharedFunctions.getPrice(payment.amount)} to "
  //       "${isSupplier? "supplier": "client"} $clientName will be due in "
  //       "${SharedFunctions.getDate(payment.dueDate ?? 0)}";
  //
  //   await (await SharedPreferences.getInstance()).setString(
  //     payment.id,
  //     NotificationModel(
  //       pushAt: payment.notifyAt!,
  //       body: notificationBody
  //     ).toString()
  //   );
  //
  // }
}

