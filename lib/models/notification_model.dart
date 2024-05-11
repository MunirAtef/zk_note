
import 'dart:convert';

class NotificationModel {
  int pushAt;
  String body;

  NotificationModel({
    required this.pushAt,
    required this.body
  });

  factory NotificationModel.fromJson(String stringSource) {
    Map json = jsonDecode(stringSource);
    return NotificationModel(pushAt: json["pushAt"], body: json["body"]);
  }
  @override
  String toString() {
    return jsonEncode({
      "pushAt": pushAt,
      "body": body
    });
  }
}
