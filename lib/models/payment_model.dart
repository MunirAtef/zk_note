

class PaymentModel {
  String id;
  String clientId;
  double amount;
  String paymentMethod;
  int date;
  int? dueDate;
  int? notifyAt;
  bool isNorm;

  PaymentModel({
    required this.id,
    required this.clientId,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    required this.dueDate,
    required this.notifyAt,
    required this.isNorm
  });

  Map<String, dynamic> toJson() => {
    "clientId": clientId,
    "amount": amount,
    "paymentMethod": paymentMethod,
    "date": date,
    "isNorm": isNorm,
    if (dueDate != null) "dueDate": dueDate,
    if (notifyAt != null) "notifyAt": notifyAt
  };

  factory PaymentModel.fromJson(String id, dynamic json) => PaymentModel(
    id: id,
    clientId: json["clientId"],
    amount: json["amount"],
    paymentMethod: json["paymentMethod"],
    date: json["date"],
    dueDate: json["dueDate"],
    notifyAt: json["notifyAt"],
    isNorm: json["isNorm"]
  );
}

