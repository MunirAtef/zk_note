
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../export/export_invoice.dart';
import '../../firebase/firestore.dart';
import '../../models/client_model.dart';
import '../../models/invoice_model.dart';
import '../../shared/invoice_data.dart';
import '../../shared/main_colors.dart';
import '../../shared/shared_functions.dart';
import '../../shared_widgets/confirm_dialog.dart';
import '../../shared_widgets/custom_snake_bar.dart';
import '../../shared_widgets/input_dialog.dart';
import '../../shared_widgets/screen_background.dart';
import '../client_page/client_page_cubit.dart';
import 'invoice_details_state.dart';


class InvoiceDetailsCubit extends Cubit<InvoiceDetailsState> {
  late InvoiceModel invoiceModel;
  late ClientModel clientModel;
  InvoiceDetailsCubit(): super(InvoiceDetailsState());

  static InvoiceModel? copiedInvoice;
  bool isLoading = true;

  void setInitial(ClientModel clientModel, InvoiceModel invoiceModel) async {
    this.invoiceModel = invoiceModel;
    this.clientModel = clientModel;
    isLoading = true;
    var details = await Firestore.getInvoiceDetails(invoiceModel.id);
    invoiceModel.detailsFromJson(details);
    isLoading = false;
    emit(InvoiceDetailsState.setTrue());
  }

  static InvoiceDetailsCubit getInstance(BuildContext context) =>
    BlocProvider.of<InvoiceDetailsCubit>(context);

  List<int> selectedTableItems = [];

  void updateItemsTable() {
    emit(InvoiceDetailsState(updateTable: true));
  }

  Map<String, dynamic> getMetaData() => {
    "Type": "${invoiceModel.type} INVOICE",
    "Invoice No.": invoiceModel.invoiceNum,
    "Invoice date": Shared.getDate(invoiceModel.date),
    "Original price": Shared.getPrice(invoiceModel.totalPrice),
    "Price after discount":
      Shared.getPrice(invoiceModel.priceAfterDiscount),
  };  // if (invoiceModel.totalPrice > invoiceModel.priceAfterDiscount)

  void deleteInvoice(BuildContext context) {
    CustomSnackBar csb = CustomSnackBar(
      context: context,
      subColor: MainColors.clientPage
    );

    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: "DELETE INVOICE",
        content: "Are you sure you want to delete this invoice",
        color: MainColors.invoiceDetailsPage,
        onConfirm: () async {
          NavigatorState navigator = Navigator.of(context);
          ClientPageCubit clientPageCubit = ClientPageCubit.getInstance(context);
          await Firestore.deleteInvoice(invoiceModel);

          if (invoiceModel.type == InvoiceTypes.returned) {
            clientModel.transPayments.totalRetTrans -= invoiceModel.priceAfterDiscount;
          } else {
            clientModel.transPayments.totalNorTrans -= invoiceModel.priceAfterDiscount;
          }

          navigator.pop();
          clientPageCubit.clientInvoices?.removeWhere((e) =>
            e.id == invoiceModel.id);
          clientPageCubit.updateInvoices();
          csb.show("Invoice deleted successfully");
          return true;
        },
      )
    );
  }


  void copyInvoice(BuildContext context) {
    if (isLoading) {
      Fluttertoast.showToast(msg: "Wait to be loaded");
      return;
    }

    copiedInvoice = InvoiceModel(
      id: invoiceModel.id,
      clientId: invoiceModel.clientId,
      date: invoiceModel.date,
      type: invoiceModel.type,
      invoiceNum: invoiceModel.invoiceNum,
      comment: invoiceModel.comment,
      totalPrice: invoiceModel.totalPrice,
      priceAfterDiscount: invoiceModel.priceAfterDiscount,
      invoiceItems: List.from(invoiceModel.invoiceItems ?? [])
    );

    CustomSnackBar(context: context, subColor: MainColors.invoiceDetailsPage)
      .show("Invoice copied");
  }


  void deleteComment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: "DELETE COMMENT",
        content: "Are you sure you want to delete this comment",
        color: MainColors.invoiceDetailsPage,
        onConfirm: () async {
          await Firestore.updateInvDetails(invoiceModel.id, {
            "comment": FieldValue.delete()
          });

          invoiceModel.comment = null;
          emit(InvoiceDetailsState(updateComment: true));
          return true;
        },
      )
    );
  }

  void editComment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => InputDialog(
        title: "UPDATE COMMENT",
        color: MainColors.invoiceDetailsPage,
        hint: 'Comment',
        defaultText: invoiceModel.comment,
        multiLine: true,
        prefix: const Icon(Icons.comment),

        onConfirm: (String comment) async {
          if (comment == "") {
            Fluttertoast.showToast(msg: "No comment entered");
            return false;
          }
          await Firestore.updateInvDetails(invoiceModel.id, {"comment": comment});

          invoiceModel.comment = comment;
          emit(InvoiceDetailsState(updateComment: true));
          return true;
        },
      )
    );
  }

  void pdfPreview(BuildContext context) async {
    NavigatorState navigator = Navigator.of(context);
    var generateInvoice =
    ExportInvoice(invoiceModel, clientModel).generateInvoice();

    String path = "${(await getTemporaryDirectory()).path}/"
      "invoice-${Shared.getDateForPath(invoiceModel.date)}.pdf";

    Uint8List bytes = await (await generateInvoice).save();
    await File(path).writeAsBytes(bytes);

    navigator.push(
      MaterialPageRoute(
        builder: (context) => ScreenBackground(
          appBarColor: Colors.grey,
          title: "INVOICE PREVIEW",
          action: IconButton(
            onPressed: () {
              Share.shareXFiles([XFile(path)]);
            },
            icon: const Icon(Icons.share, color: Colors.white)
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25)
              ),
              child: PDFView(filePath: path),
            ),
          )
        ),
      )
    );
  }
}

