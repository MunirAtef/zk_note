
import 'package:zk_note/models/governorate_model.dart';

class CityModel extends GovernorateModel {
  CityModel.fromJson(dynamic json) {
    super.parseJson(json);
  }

  CityModel() {
    super.setDefault();
  }
}


