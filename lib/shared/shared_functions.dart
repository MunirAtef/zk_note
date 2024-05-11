
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zk_note/general/connectivity.dart';
import 'package:zk_note/models/trans_payments_model.dart';

class Shared {
  static bool governorateEnglish = true;

  static bool isConnected(bool showToast) {
    if (ConnectivityCheck.isConnected) return true;
    if (showToast) Fluttertoast.showToast(msg: "No internet connection");
    return false;
  }

  static String getDate(int timestamp) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dt.day}/${dt.month}/${dt.year}";
  }


  static String getPrice(double price) {
    return "${price.toStringAsFixed(1)} EGP";
  }

  static String amountOwed(TransPaymentsModel payments, bool isSupplier) {
    double totalPrice = payments.totalNorTrans - payments.totalRetTrans
      - payments.totalNorPay + payments.totalRetPay;

    double absAmount = totalPrice > 0? totalPrice: -totalPrice;
    String price = getPrice(absAmount);

    /// the amount owed to you
    if (isSupplier) {
      if (totalPrice > 0) return "Amount owed to supplier: $price";
      if (totalPrice < 0) return "Amount owed to you: $price";
    } else {
      if (totalPrice > 0) return "Amount owed to you: $price";
      if (totalPrice < 0) return "Amount owed to client: $price";
    }

    return "No amount owned";
  }

  static String getDateForPath(int timestamp) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dt.day}_${dt.month}_${dt.year}";
  }

  // static String dateFormatter2(int timestamp) {
  //   List<String> months = ['January', 'February', 'March', 'April', 'May',
  //     'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  //
  //   DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  //
  //   return "${months[date.month - 1]} ${date.day}, ${date.year}";
  // }
}
