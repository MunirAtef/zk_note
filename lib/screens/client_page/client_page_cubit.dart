
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zk_note/export/export_statement.dart';
import 'package:zk_note/firebase/firestore.dart';
import 'package:zk_note/firebase/storage.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/invoice_model.dart';
import 'package:zk_note/models/payment_model.dart';
import 'package:zk_note/screens/add_payment/add_payment_ui.dart';
import 'package:zk_note/screens/add_transaction/add_transaction_ui.dart';
import 'package:zk_note/screens/client_page/add_categories_dialog.dart';
import 'package:zk_note/screens/client_page/client_page_state.dart';
import 'package:zk_note/screens/client_page/settings_bottom_sheet/client_settings_ui.dart';
import 'package:zk_note/screens/client_page/settings_bottom_sheet/update_address_dialog.dart';
import 'package:zk_note/screens/clients_list/clients_list_cubit.dart';
import 'package:zk_note/screens/clients_list/clients_list_state.dart';
import 'package:zk_note/screens/invoice_details/invoice_details_ui.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/pick_image.dart';
import 'package:zk_note/shared/shared_functions.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/confirm_dialog.dart';
import 'package:zk_note/shared_widgets/input_dialog.dart';
import 'package:zk_note/shared_widgets/loading_dialog.dart';

import '../../shared_widgets/screen_background.dart';

class ClientPageCubit extends Cubit<ClientPageState> {
  ClientPageCubit(): super(ClientPageState());

  late BuildContext context;
  late ClientModel clientModel;

  List<InvoiceModel>? clientInvoices;
  List<PaymentModel>? payments;

  double totalPrice = 0;


  static ClientPageCubit getInstance(BuildContext context) =>
    BlocProvider.of<ClientPageCubit>(context);

  void setInitial(BuildContext context, ClientModel clientModel) async {
    this.context = context;
    this.clientModel = clientModel;

    clientInvoices = null;
    payments = null;

    totalPrice = 0;

    clientInvoices = await Firestore.getClientInvoices(clientModel.id);
    clientInvoices?.sort((a, b) => b.date.compareTo(a.date));
    emit(ClientPageState(updateInvoices: true));

    payments = await Firestore.getClientPayments(clientModel.id);
    payments?.sort((a, b) => b.date.compareTo(a.date));

    emit(ClientPageState(updatePayments: true));
  }


  Map<String, String> totalAmountsData() {
    double totalNorTrans = clientModel.transPayments.totalNorTrans;
    double totalRetTrans = clientModel.transPayments.totalRetTrans;
    double totalNorPay = clientModel.transPayments.totalNorPay;
    double totalRetPay = clientModel.transPayments.totalRetPay;

    totalPrice = totalNorTrans - totalRetTrans - totalNorPay + totalRetPay;

    Map<String, String> data = {
      clientModel.isSupplier? "Total purchases": "Total sales":
        Shared.getPrice(totalNorTrans),

      "Total returned": Shared.getPrice(totalRetTrans),
    };

    if (clientModel.isSupplier) {
      data["Total outbound"] = Shared.getPrice(totalNorPay);
      if (totalRetPay > 0) data["Total inbound"] = Shared.getPrice(totalRetPay);
    } else {
      data["Total inbound"] = Shared.getPrice(totalNorPay);
      if (totalRetPay > 0) data["Total outbound"] = Shared.getPrice(totalRetPay);
    }

    return data;
  }

  String? getAddress() {
    String? address;

    if (clientModel.governorate != null) {
      address = clientModel.governorate?.name;
      if (clientModel.city != null) address = "$address / ${clientModel.city?.name}";
      if (clientModel.address != null) address = "$address (${clientModel.address})";
      return address;
    }
    return null;
  }

  void addPhoneNumber() {
    showDialog(
      context: context,
      builder: (context) {
        return InputDialog(
          title: "ADD PHONE NUMBER",
          hint: "Phone number",
          prefix: const Icon(Icons.phone),
          color: MainColors.clientPage,
          keyboardType: TextInputType.phone,
          onConfirm: (String phone) async {
            if (phone.isEmpty) {
              Fluttertoast.showToast(msg: "No number entered");
              return false;
            } else if (clientModel.phones.contains(phone)) {
              Fluttertoast.showToast(msg: "Phone number already exists");
              return false;
            }

            await Firestore.addPhoneNumber(clientModel.id, phone);
            clientModel.phones.add(phone);
            emit(ClientPageState(updatePhonesList: true));
            return true;
          },
        );
      }
    );
  }

  void makeCall(String phone) {
    launchUrl(
      Uri.parse("tel://$phone"),
      mode: LaunchMode.externalApplication
    );
  }

  void chatWhatsapp(String phone) {
    launchUrl(Uri.parse("https://wa.me/$phone"),
      mode: LaunchMode.externalApplication
    );
  }

  void deletePhoneNumber(String phone) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmDialog(
          title: "DELETE PHONE NUMBER",
          content: "Are you sure you want to delete the phone number $phone",
          color: MainColors.clientPage,
          onConfirm: () async {
            await Firestore.deletePhoneNumber(clientModel.id, phone);
            clientModel.phones.remove(phone);
            emit(ClientPageState(updatePhonesList: true));
            return true;
          },
        );
      }
    );
  }


  void addCategories() {
    List<int> includedCategories = [
      for (int i in UserData.categoriesKey)
        if (!clientModel.categories.contains(i)) i
    ];

    if (includedCategories.isEmpty) {
      Fluttertoast.showToast(msg: "Client has all categories");
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AddCategoriesDialog(
          includedCategories: includedCategories,
          onConfirm: (List<int> checkedCategories) async {
            await Firestore.addClientCategories(clientModel.id, checkedCategories);
            clientModel.categories.addAll(checkedCategories);
            emit(ClientPageState(updateCategoriesList: true));
          },
        );
      }
    );
  }

  void deleteCategory(int categoryId) {
    String category = UserData.categoriesMap[categoryId].toString();

    showDialog(
      context: context,
      builder: (context) {
        return ConfirmDialog(
          title: "DELETE CATEGORY",
          content: "Are you sure you want to delete $category category",
          color: MainColors.clientPage,
          onConfirm: () async {
            await Firestore.deleteClientCategory(clientModel.id, categoryId);
            clientModel.categories.remove(categoryId);
            emit(ClientPageState(updateCategoriesList: true));
            return true;
          },
        );
      }
    );
  }

  void addTransaction() {
    print(clientModel.id);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddTransaction(clientModel: clientModel)
    ));
  }

  void openInvoiceDetails(int index) {
    if (clientInvoices == null) return;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => InvoiceDetails(
        clientModel: clientModel,
        invoiceModel: clientInvoices![index]
      )
    ));
  }

  void addPayment() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddPayment(clientModel: clientModel)
    ));
  }

  /// invoices
  void updateInvoices() {
    emit(ClientPageState(updateInvoices: true));
  }

  void updatePayments() {
    emit(ClientPageState(updatePayments: true));
  }

  void onSelectPayment(int index) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: "DELETE PAYMENT",
        content: "Are you sure you want to delete this payment",
        color: MainColors.clientPage,
        onConfirm: () async {
          await Firestore.deletePayment(payments![index]);
          PaymentModel payment = payments!.removeAt(index);
          if (payment.isNorm) {
            clientModel.transPayments.totalNorPay -= payment.amount;
          } else {
            clientModel.transPayments.totalRetPay -= payment.amount;
          }

          emit(ClientPageState(updatePayments: true));
          return true;
        },
      )
    );
  }


  String amountOwed() => Shared.amountOwed(
    clientModel.transPayments,
    clientModel.isSupplier
  );


  void statementPreview(BuildContext context) async {
    NavigatorState navigator = Navigator.of(context);
    var generateInvoice =
    ExportStatement(clientInvoices ?? [], payments ?? [], clientModel).generateInvoice();

    String path = "${(await getTemporaryDirectory()).path}/"
      "statement-${Shared.getDateForPath(DateTime.now().millisecondsSinceEpoch)}.pdf";

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


  /// Settings
  void openBottomSheet() {
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(
        maxHeight: 350
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
      ),
      builder: (BuildContext context) => const ClientSettings(),
    );
  }

  void updateWithMessage(String? message) {
    ClientsListCubit clientsCubit = BlocProvider.of<ClientsListCubit>(context);

    emit(ClientPageState(updateMainData: true));
    clientsCubit.emit(ClientsListState(updateList: true));

    if (message != null) {
      Fluttertoast.showToast(msg: message);
    }
  }

  Future<void> updateImage() async {
    NavigatorState navigator = Navigator.of(context);
    navigator.pop();

    File? pickedImage = await PickImage.pickImage(
      context: context,
      color: MainColors.clientSettingsPage,
      onDelete: clientModel.imageUrl == null? null: () async {
        navigator.pop();

        showLoading(
          context: context,
          title: "DELETING IMAGE",
          color: MainColors.clientSettingsPage,
          waitFor: () async {
            await Firestore.updateClientData(
              clientModel.id,
              { "imageUrl": FieldValue.delete() }
            );

            clientModel.imageUrl = null;
            updateWithMessage("Image deleted successfully");
          }
        );
      }
    );

    if (pickedImage == null) return;

    showLoading(
      context: context,
      title: "UPDATING IMAGE",
      color: MainColors.clientSettingsPage,
      waitFor: () async {
        String? imageExt = pickedImage.path.split(".").last;

        String? imageUrl = await Storage.uploadFile(
          path: StoragePaths.client(clientModel.id, "image.$imageExt"),
          file: pickedImage
        );

        await Firestore.updateClientData(clientModel.id, { "imageUrl": imageUrl });
        clientModel.imageUrl = imageUrl;

        updateWithMessage("Image updated successfully");
      }
    );
  }

  Future<void> updateName() async {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) {
        return InputDialog(
          title: "UPDATE CLIENT NAME",
          hint: "Enter new name",
          defaultText: clientModel.name,
          prefix: const Icon(Icons.person),
          color: MainColors.clientSettingsPage,
          onConfirm: (String newName) async {
            if (newName.isEmpty) {
              Fluttertoast.showToast(msg: "No name entered");
              return false;
            }

            await Firestore.updateClientData(clientModel.id, { "name": newName });
            clientModel.name = newName;
            updateWithMessage("Client name updated successfully");
            return true;
          },
        );
      }
    );
  }

  Future<void> updateAddress() async {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => UpdateAddressDialog(
        defaultAddress: clientModel.address,
        onConfirm: (address, governorate, city) async {
          String? nullableAddress = address?.isEmpty == true? null : address;

          await Firestore.updateClientData(
            clientModel.id,
            {
              "address": nullableAddress,
              "governorate": governorate?.toJson(),
              "city": city?.toJson(),
            }
          );

          clientModel.address = nullableAddress;
          clientModel.governorate = governorate;
          clientModel.city = city;
          updateWithMessage("Address updated successfully");
        }
      )
    );
  }

  Future<void> deleteClient() async {
    Navigator.pop(context);
    ClientsListCubit clientsCubit = BlocProvider.of<ClientsListCubit>(context);

    showDialog(
      context: context,
      builder: (context) {
        return ConfirmDialog(
          title: "DELETE CLIENT",
          content: "Are you sure you want to delete client ${clientModel.name}",
          color: MainColors.clientSettingsPage,
          onConfirm: () async {
            NavigatorState navigator = Navigator.of(context);

            await Firestore.deleteClient(clientModel.id);
            navigator.pop();

            clientsCubit.clientModels?.removeWhere((ClientModel element) =>
              element.id == clientModel.id);

            clientsCubit.emit(ClientsListState(updateList: true));
            return true;
          },
        );
      }
    );
  }
}

