
class TransPaymentsModel {
  late double totalNorTrans;
  late double totalRetTrans;

  late double totalNorPay;
  late double totalRetPay;

  TransPaymentsModel({
    this.totalNorTrans = 0,
    this.totalRetTrans = 0,
    this.totalNorPay = 0,
    this.totalRetPay = 0
  });

  TransPaymentsModel.fromJson(dynamic json) {
    totalNorTrans = json["totalNorTrans"];
    totalRetTrans = json["totalRetTrans"];
    totalNorPay = json["totalNorPay"];
    totalRetPay = json["totalRetPay"];
  }

  Map<String, double> toJson() => {
    "totalNorTrans": totalNorTrans,
    "totalRetTrans": totalRetTrans,
    "totalNorPay": totalNorPay,
    "totalRetPay": totalRetPay
  };
}
