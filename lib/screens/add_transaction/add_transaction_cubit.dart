
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zk_note/firebase/firestore.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/invoice_item_model.dart';
import 'package:zk_note/models/invoice_model.dart';
import 'package:zk_note/screens/add_transaction/add_transaction_state.dart';
import 'package:zk_note/screens/client_page/client_page_cubit.dart';
import 'package:zk_note/screens/invoice_details/invoice_details_cubit.dart';
import 'package:zk_note/shared/invoice_data.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/shared_functions.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/input_dialog.dart';

import '../../shared_widgets/custom_snake_bar.dart';


class AddTransactionCubit extends Cubit<AddTransactionState> {
  AddTransactionCubit(): super(AddTransactionState());

  static AddTransactionCubit getInstance(BuildContext context) =>
    BlocProvider.of<AddTransactionCubit>(context);

  void setInitial(ClientModel clientModel, InvoiceModel? initialInvoice) {
    this.clientModel = clientModel;

    invoiceDate = DateTime.now().millisecondsSinceEpoch;

    if (clientModel.isSupplier) {
      invoiceType ??= InvoiceTypes.purchase;
    } else {
      invoiceType ??= InvoiceTypes.sales;
    }
    anotherInvoiceType ??= InvoiceTypes.returned;
  }


  late ClientModel clientModel;

  late int invoiceDate;

  String? invoiceType;
  String? anotherInvoiceType;

  TextEditingController invoiceNumController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemCountController = TextEditingController();
  TextEditingController unitPriceController = TextEditingController();
  TextEditingController discountController = TextEditingController();


  bool showSwitchInvoice = false;

  String selectedUnit = UserData.units[0];

  List<InvoiceItemModel> invoiceItems = [];

  double? currentItemPrice;
  double? totalPrice;

  bool isLoading = false;
  List<int> selectedTableItems = [];

  int? itemToBeUpdated;

  bool useDiscountAmount = false;
  double priceAfterDiscount = 0;


  void pasteInvoice() {
    InvoiceModel? invoiceModel = InvoiceDetailsCubit.copiedInvoice;
    if (invoiceModel == null) return;

    invoiceDate = invoiceModel.date;
    invoiceNumController.text = invoiceModel.invoiceNum;
    commentController.text = invoiceModel.comment ?? "";
    invoiceItems.clear();
    invoiceItems.addAll(invoiceModel.invoiceItems ?? []);

    calcTotalInvoicePrice();
    getPriceAfterDiscount();

    /// discount section
    // useDiscountAmount = true;
    // double discountAmount = totalPrice! - invoiceModel.priceAfterDiscount;
    // if (discountAmount > 0.01) {
    //   discountController.text = discountAmount.toStringAsFixed(2);
    // }

    emit(AddTransactionState.setTrue());
  }

  void showAnotherInvoiceType() {
    showSwitchInvoice = !showSwitchInvoice;
    emit(AddTransactionState(updateInvoiceType: true));
  }

  void switchInvoiceType() {
    String? temp = invoiceType;
    invoiceType = anotherInvoiceType;
    anotherInvoiceType = temp;
    showSwitchInvoice = false;

    emit(AddTransactionState(updateInvoiceType: true));
  }

  void calcTotalInvoicePrice() {
    if (invoiceItems.isEmpty) null;

    totalPrice = 0;
    for (InvoiceItemModel item in invoiceItems) {
      totalPrice = totalPrice! + item.count * item.price;
    }
  }

  void updateCurrentTotalPrice() {
    int? itemCount = int.tryParse(itemCountController.text.trim());
    double? unitPrice = double.tryParse(unitPriceController.text.trim());

    if (itemCount == null || unitPrice == null) {
      currentItemPrice = null;
    } else {
      currentItemPrice = itemCount * unitPrice;
    }

    emit(AddTransactionState(updateCurrentPrice: true));
  }


  void onSelectTableItems() {
    emit(AddTransactionState(updateItemsTable: true));
  }

  void deleteTableRows() {
    selectedTableItems.sort((a, b) => b.compareTo(a));

    for (int i in selectedTableItems) {
      InvoiceItemModel removedItem = invoiceItems.removeAt(i);
      totalPrice = totalPrice! - removedItem.count * removedItem.price;
    }

    if (itemToBeUpdated != null) {
      itemToBeUpdated = null;
      onCancelUpdate();
    }

    if (invoiceItems.isEmpty) totalPrice = null;

    selectedTableItems.clear();
    getPriceAfterDiscount();
    emit(AddTransactionState(updateItemsTable: true));
  }

  void updateTableRow() {
    itemToBeUpdated = selectedTableItems[0];
    InvoiceItemModel invoiceItem = invoiceItems[itemToBeUpdated!];
    itemNameController.text = invoiceItem.name;
    itemCountController.text = invoiceItem.count.toString();
    unitPriceController.text = invoiceItem.price.toString();
    selectedUnit = invoiceItem.unit;
    currentItemPrice = invoiceItem.count * invoiceItem.price;

    emit(AddTransactionState(updateAddItemSection: true));
  }

  void onCancelUpdate() {
    itemToBeUpdated = null;
    _resetAddItemSection();
    emit(AddTransactionState(updateAddItemSection: true));
  }


  void onDateChange(int newDate) {
    invoiceDate = newDate;
    emit(AddTransactionState(updateInvoiceDate: true));
  }


  void updateUnit(String? newUnit) {
    if (newUnit == null) return;
    selectedUnit = newUnit;
    emit(AddTransactionState(updateItemUnit: true));
  }

  void addNewUnit(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InputDialog(
          title: "ADD NEW UNIT",
          hint: "Unit name",
          prefix: const Icon(Icons.category_outlined, size: 24),
          color: MainColors.addTransactionPage,
          onConfirm: (String unit) async {
            if (unit.isEmpty) {
              Fluttertoast.showToast(msg: "No unit entered");
              return false;
            }

            await Firestore.addNewUnit(unit);
            UserData.units.add(unit);
            selectedUnit = unit;
            emit(AddTransactionState(updateItemUnit: true));
            return true;
          },
        );
      }
    );
  }

  void addOrUpdateItem() {
    String itemName = itemNameController.text.trim();
    int? itemCount = int.tryParse(itemCountController.text.trim());
    double? unitPrice = double.tryParse(unitPriceController.text.trim());

    if (itemName.isEmpty) return endWithMsg("No item name entered");
    if (itemCount == null) return endWithMsg("Enter the correct item count");
    if (unitPrice == null) return endWithMsg("Enter the correct unit price");

    double itemPrice = itemCount * unitPrice;
    if (itemPrice <= 0) return endWithMsg("Price must be bigger than 0");

    InvoiceItemModel invoiceItem = InvoiceItemModel(
      name: itemName,
      count: itemCount,
      price: unitPrice,
      unit: selectedUnit
    );

    if (itemToBeUpdated != null) {
      invoiceItems[itemToBeUpdated!] = invoiceItem;
      itemToBeUpdated = null;
      calcTotalInvoicePrice();
      Fluttertoast.showToast(msg: "Item updated");
    } else {
      invoiceItems.add(invoiceItem);
      totalPrice = (totalPrice ?? 0) + itemPrice;
      Fluttertoast.showToast(msg: "Item added to the list");
    }

    _resetAddItemSection();
    getPriceAfterDiscount();

    emit(AddTransactionState(
      updateAddItemSection: true,
      updateItemsTable: true,
      updateInvoicePrice: true
    ));
  }

  void updateDiscountType(bool? newType) {
    if (newType != null) useDiscountAmount = newType;
    discountController.clear();
    getPriceAfterDiscount();
    emit(AddTransactionState(updateInvoicePrice: true));
  }

  void updatePriceAfterDiscount(_) {
    getPriceAfterDiscount();
    emit(AddTransactionState(updateInvoicePrice: true));
  }

  String? getPriceAfterDiscount() {
    if (totalPrice == null) return null;
    priceAfterDiscount = totalPrice!;  /// initially, may be not changed

    String discountText = discountController.text.trim();
    if (discountText.isEmpty) return null;

    if (useDiscountAmount) {
      double? discountAmount = double.tryParse(discountText);

      if (discountAmount == null) return "Enter correct discount percentage";
      if (discountAmount < 0) return "Discount amount must be bigger than 0";
      if (discountAmount > totalPrice!) return "Amount must be less the total price";

      priceAfterDiscount = totalPrice! - discountAmount;
    } else {
      int? discountPercentage = int.tryParse(discountText);

      if (discountPercentage == null) return "Enter correct discount percentage";
      if (discountPercentage < 0 || discountPercentage > 100) {
        return "Percentage must be between 0 and 100";
      }

      priceAfterDiscount = totalPrice! * (1 - discountPercentage / 100);
    }

    return "Price after discount: ${Shared.getPrice(priceAfterDiscount)}";
  }


  void _resetAddItemSection() {
    itemNameController.clear();
    itemCountController.clear();
    unitPriceController.clear();
    selectedUnit = UserData.units[0];
    currentItemPrice = null;
  }

  void clearPage() {
    invoiceNumController.clear();
    commentController.clear();
    invoiceItems.clear();
    selectedTableItems.clear();
    discountController.clear();

    totalPrice = null;
    itemToBeUpdated = null;
    isLoading = false;
    showSwitchInvoice = false;
    useDiscountAmount = false;
    priceAfterDiscount = 0;

    _resetAddItemSection();
  }

  void endWithMsg(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  void addTransaction(BuildContext context) async {
    String invoiceNum = invoiceNumController.text.trim();

    if (invoiceNum.isEmpty) return endWithMsg("Enter invoice number");
    if (invoiceItems.isEmpty) return endWithMsg("Add at least one item");
    FocusScope.of(context).unfocus();

    String? comment = commentController.text.trim();
    comment = comment.isEmpty? null: comment;
    String invoiceId = Firestore.getId();

    CustomSnackBar csb = CustomSnackBar(
      context: context,
      subColor: MainColors.addTransactionPage
    );

    InvoiceModel invoiceModel = InvoiceModel(
      id: invoiceId,
      clientId: clientModel.id,
      date: invoiceDate,
      type: invoiceType!,
      invoiceNum: invoiceNum,
      comment: comment,
      totalPrice: totalPrice!,
      priceAfterDiscount: priceAfterDiscount,
      invoiceItems: List.from(invoiceItems)
    );

    ClientPageCubit clientPageCubit = ClientPageCubit.getInstance(context);

    isLoading = true;
    emit(AddTransactionState(updateLoading: true));

    bool result = await Firestore.uploadInvoiceDoc(invoiceModel);

    if (!result) {
      isLoading = false;
      emit(AddTransactionState(updateLoading: true));
      return;
    }

    if (invoiceType == InvoiceTypes.returned) {
      clientModel.transPayments.totalRetTrans += invoiceModel.priceAfterDiscount;
    } else {
      clientModel.transPayments.totalNorTrans += invoiceModel.priceAfterDiscount;
    }

    clearPage();
    emit(AddTransactionState.setTrue());
    csb.show("Invoice added successfully");

    clientPageCubit.clientInvoices?.insert(0, invoiceModel);
    clientPageCubit.clientInvoices?.sort((a, b) => b.date.compareTo(a.date));
    clientPageCubit.updateInvoices();
  }
}

