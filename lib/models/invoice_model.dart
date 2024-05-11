
import 'package:zk_note/models/invoice_item_model.dart';

class InvoiceModel {
  late String id;
  late String clientId;
  late int date;
  late String type;
  late String invoiceNum;
  String? comment;
  List<InvoiceItemModel>? invoiceItems;

  double totalPrice;
  double priceAfterDiscount;

  InvoiceModel({
    required this.id,
    required this.clientId,
    required this.date,
    required this.type,
    required this.invoiceNum,
    this.comment,
    this.invoiceItems,
    this.totalPrice = 0,
    this.priceAfterDiscount = 0
  });

  factory InvoiceModel.fromJson(String id, dynamic json) => InvoiceModel(
    id: id,
    clientId: json["clientId"],
    date: json["date"],
    type: json["type"],
    invoiceNum: json["invoiceNum"],
    totalPrice: json["totalPrice"],
    priceAfterDiscount: json["priceAfterDiscount"] ?? json["totalPrice"],
  );

  void detailsFromJson(dynamic details) {
    comment = details["comment"];
    invoiceItems = InvoiceItemModel.fromJsonList(details["invoiceItems"]);
  }

  Map<String, dynamic> toJson() => {
    "clientId": clientId,
    "date": date,
    "type": type,
    "invoiceNum": invoiceNum,
    "totalPrice": totalPrice,
    "priceAfterDiscount": priceAfterDiscount
  };

  Map<String, dynamic> detailsToJson() => {
    "comment": comment,
    "invoiceItems": InvoiceItemModel.toJsonList(invoiceItems ?? [])
  };
}


