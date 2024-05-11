
import '../firebase/firestore.dart';

List<String> adminsIds = [
  "6G1O7Jd98HcBP"
  "lqsNGu"
  "izUt1YOC2"
];

class UserData {
  static late String uid;
  static String? token;

  static Map<int, String> categoriesMap = {};
  static List<int> categoriesKey = [];
  static List<String> units = [];

  static String? mpName;
  static String? mpLogo;

  static bool isAdmin = false;
  static String? adminPassword;



  static Future<bool> getData(String uid) async {
    UserData.uid = uid;
    Map? userData = await Firestore.getUserData() as Map?;

    if (userData == null || userData.isEmpty) return false;

    categoriesMap.clear();
    categoriesKey.clear();

    mpName = userData["mpName"];
    mpLogo = userData["mpLogo"];

    isAdmin = userData["isAdmin"] ?? false;
    adminPassword = userData["adminPassword"];

    (userData["categories"] as Map? ?? {}).forEach((key, value) {
      int keyInt = int.parse("$key");
      categoriesMap[keyInt] = "$value";
      categoriesKey.add(keyInt);
    });

    categoriesKey.sort();
    units = ["Unit", ...(userData["units"] as List? ?? []).map((e) => "$e").toList()];

    return true;
  }


  static void clear() {
    uid = "";
    token = null;
    categoriesMap.clear();
    categoriesKey.clear();
    units.clear();
    mpName = null;
    mpLogo = null;
  }
}


