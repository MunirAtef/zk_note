
class InvoiceItemModel {
  late String name;
  late int count;
  late double price;
  late String unit;

  InvoiceItemModel({
    required this.name,
    required this.count,
    required this.price,
    required this.unit
  });

  InvoiceItemModel.fromJson(dynamic json) {
    name = json["name"];
    count = json["count"];
    price = json["price"];
    unit = json["unit"];
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "count": count,
    "price": price,
    "unit": unit
  };

  static List<InvoiceItemModel> fromJsonList(dynamic json) {
    json as List;
    return json.map((e) => InvoiceItemModel.fromJson(e)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<InvoiceItemModel> items) {
    return items.map((e) => e.toJson()).toList();
  }
}

