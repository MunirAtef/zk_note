
import '../shared/shared_functions.dart';

class GovernorateModel {
  late String id;
  late String name;
  late String nameEn;
  late String nameAr;

  GovernorateModel.fromJson(dynamic json) {
    parseJson(json);
  }

  GovernorateModel() {
    setDefault();
  }

  void parseJson(dynamic json) {
    bool en = Shared.governorateEnglish;

    id = json["id"];
    nameAr = json["nameAr"];
    nameEn = json["nameEn"];
    name = en? nameEn: nameAr;
  }

  void setDefault() {
    id = "";
    name = "All";
    nameEn = "All";
    nameAr = "All";
  }

  Map<String, String> toJson() => {
    "id": id,
    "nameAr": nameAr,
    "nameEn": nameEn
  };
}

