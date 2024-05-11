
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:zk_note/models/city_model.dart';
import 'package:zk_note/models/governorate_model.dart';

class CityHandler {
  static List<GovernorateModel> governorates = [];
  static Map? _cities;

  static Future<List<GovernorateModel>> getGovernorates() async {
    if (governorates.isEmpty) {
      String jsonData =
        await rootBundle.loadString('assets/json_data/governorates.json');
      governorates = (json.decode(jsonData) as List).map((e) => GovernorateModel.fromJson(e)).toList();
    }

    return governorates;
  }

  static Future<List<CityModel>> getCities(String governorateId) async {
    if (_cities == null) {
      String jsonData =
        await rootBundle.loadString('assets/json_data/cities.json');
      _cities = json.decode(jsonData);
    }

    return (_cities![governorateId] as List).map((e) => CityModel.fromJson(e)).toList();
  }
}
