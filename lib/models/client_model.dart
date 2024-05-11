
import 'city_model.dart';
import 'governorate_model.dart';
import 'trans_payments_model.dart';

class ClientModel {
  late String id;
  late String name;
  late bool isSupplier;
  String? imageUrl;
  String? address;
  GovernorateModel? governorate;
  CityModel? city;
  TransPaymentsModel transPayments = TransPaymentsModel();
  List<String> phones = [];
  List<int> categories = [];

  ClientModel({
    this.id = "",
    required this.name,
    required this.isSupplier,
    this.imageUrl,
    this.address,
    this.governorate,
    this.city,
    required this.transPayments,
    this.phones = const [],
    this.categories = const []
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "isSupplier": isSupplier,
    "imageUrl": imageUrl,
    "address": address,
    "governorate": governorate?.toJson(),
    "city": city?.toJson(),
    "transPayments": transPayments.toJson(),
    "phones": phones,
    "categories": categories
  };

  ClientModel.fromJson(dynamic json) {
    id = json["id"];
    name = json["name"];
    isSupplier = json["isSupplier"];
    imageUrl = json["imageUrl"];
    address = json["address"];
    phones = (json["phones"] as List).map((e) => "$e").toList();
    categories = (json["categories"] as List).map((e) => e as int).toList();
    transPayments = TransPaymentsModel.fromJson(json["transPayments"]);

    if (json["governorate"] != null) {
      governorate = GovernorateModel.fromJson(json["governorate"]);
    }
    if (json["city"] != null) {
      city = CityModel.fromJson(json["city"]);
    }
  }
}

