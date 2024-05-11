
class UserModel {
  String mpName;
  String? mpLogo;

  UserModel({
    required this.mpName,
    this.mpLogo
  });

  factory UserModel.fromJson(dynamic json) => UserModel(
    mpName: json["mpName"],
    mpLogo: json["mpLogo"]
  );

  Map<String, dynamic> toJson() => {
    "mpName": mpName,
    "mpLogo": mpLogo
  };
}
