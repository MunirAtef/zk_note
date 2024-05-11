
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zk_note/shared/invoice_data.dart';

import '../models/client_model.dart';
import '../models/invoice_model.dart';
import '../models/payment_model.dart';
import '../shared/shared_functions.dart';
import '../shared/user_data.dart';


class FirestoreFunc {
  static final CollectionReference<Map<String, dynamic>> usersCollection =
    FirebaseFirestore.instance.collection("users");

  static DocumentReference userDoc() =>
    usersCollection.doc(UserData.uid);

  static CollectionReference clientsCollection() =>
    userDoc().collection("clients");

  static CollectionReference invoicesCollection() =>
    userDoc().collection("invoices");

  static CollectionReference invDetailsCollection() =>
    userDoc().collection("invDetails");

  static CollectionReference paymentsCollection() =>
    userDoc().collection("payments");

  ///=======================================================
  static String getId() => userDoc().collection("_").doc().id;
  ///=======================================================
  static Future<bool> uploadUserData(String mpName, String? mpLogo) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().set({
      "mpName": mpName,
      if (mpLogo != null) "mpName": mpName,
      "categories": {},
      "units": []
    });
    return true;
  }

  static Future<Object?> getUserData() async {
    if (!Shared.isConnected(false)) return false;
    return (await userDoc().get()).data();
  }

  static Future<bool> updateMpLogo(String? logoUrl) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().update({"mpLogo": logoUrl ?? FieldValue.delete()});
    return true;
  }

  static Future<bool> updateMpName(String name) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().update({"mpName": name});
    return true;
  }

  ///=======================================================
  static Future<bool> uploadClientDoc(ClientModel clientModel) async {
    if (!Shared.isConnected(true)) return false;

    await clientsCollection().doc(clientModel.id).set(clientModel.toJson());
    return true;
  }

  static Future<List<ClientModel>> getAllClients() async {
    if (!Shared.isConnected(true)) return [];

    try {
      QuerySnapshot<Object?> querySnapshot = await clientsCollection().get();
      return querySnapshot.docs.map((e) => ClientModel.fromJson(e.data())).toList();
    } on FirebaseException {
      return [];
    } catch(e) {
      return [];
    }
  }

  ///=======================================================
  static Future<bool> uploadInvoiceDoc(InvoiceModel invoice) async {
    if (!Shared.isConnected(true)) return false;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.set(invoicesCollection().doc(invoice.id), invoice.toJson());
    batch.set(invDetailsCollection().doc(invoice.id), invoice.detailsToJson());

    String ref =
      invoice.type == InvoiceTypes.returned? "totalRetTrans": "totalNorTrans";

    batch.update(clientsCollection().doc(invoice.clientId),
        {"transPayments.$ref": FieldValue.increment(invoice.priceAfterDiscount)});

    await batch.commit();
    return true;
  }

  static Future<List<InvoiceModel>> getClientInvoices(String clientId) async {
    if (!Shared.isConnected(false)) return [];

    QuerySnapshot<Object?> querySnapshot =
      await invoicesCollection().where("clientId", isEqualTo: clientId).get();

    return querySnapshot.docs.map((e) =>
      InvoiceModel.fromJson(e.id, e.data())).toList();
  }

  static Future<dynamic> getInvoiceDetails(String invoiceId) async {
    if (!Shared.isConnected(true)) return null;

    return (await invDetailsCollection().doc(invoiceId).get()).data();
  }

  static Future<bool> deleteInvoice(InvoiceModel invoice) async {
    if (!Shared.isConnected(true)) return false;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.delete(invoicesCollection().doc(invoice.id));
    batch.delete(invDetailsCollection().doc(invoice.id));

    String ref =
      invoice.type == InvoiceTypes.returned? "totalRetTrans": "totalNorTrans";

    batch.update(clientsCollection().doc(invoice.clientId),
      {"transPayments.$ref": FieldValue.increment(-invoice.priceAfterDiscount)});

    await batch.commit();
    return true;
  }

  static Future<bool> updateInvDetails(String invoiceId, dynamic data) async {
    if (!Shared.isConnected(true)) return false;

    await invDetailsCollection().doc(invoiceId).update(data);
    return true;
  }

  ///=======================================================
  static Future<bool> uploadPaymentDoc(PaymentModel payment) async {
    if (!Shared.isConnected(true)) return false;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.set(paymentsCollection().doc(payment.id), payment.toJson());

    String ref = payment.isNorm? "totalNorPay": "totalRetPay";

    batch.update(clientsCollection().doc(payment.clientId),
      {"transPayments.$ref": FieldValue.increment(payment.amount)});

    await batch.commit();
    return true;
  }

  static Future<List<PaymentModel>> getClientPayments(String clientId) async {
    if (!Shared.isConnected(false)) return [];

    QuerySnapshot<Object?> querySnapshot =
      await paymentsCollection().where("clientId", isEqualTo: clientId).get();

    return querySnapshot.docs.map((e) =>
      PaymentModel.fromJson(e.id, e.data())).toList();
  }

  static Future<bool> deletePayment(PaymentModel payment) async {
    if (!Shared.isConnected(true)) return false;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.delete(paymentsCollection().doc(payment.id));

    String ref = payment.isNorm? "totalNorPay": "totalRetPay";

    batch.update(clientsCollection().doc(payment.clientId),
      {"transPayments.$ref": FieldValue.increment(-payment.amount)});

    await batch.commit();
    return true;
  }

  static Future<List<PaymentModel>> getFutureDues() async {
    if (!Shared.isConnected(true)) return [];

    QuerySnapshot<Object?> querySnapshot =
    await paymentsCollection()
      .where("dueDate", isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
      .get();

    return querySnapshot.docs.map((e) =>
      PaymentModel.fromJson(e.id, e.data())).toList();
  }

  ///=======================================================
  static Future<bool> updateCategory(int key, String category) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().update({"categories.$key": category});
    return true;
  }

  static Future<bool> deleteCategory(int key) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().update({"categories.$key": FieldValue.delete()});
    return true;
  }

  static Future<bool> addClientCategories(String clientId, List<int> categoriesId) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc()
      .collection("clients")
      .doc(clientId)
      .update({"categories": FieldValue.arrayUnion(categoriesId)});
    return true;
  }

  static Future<bool> deleteClientCategory(String clientId, int key) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().collection("clients").doc(clientId).update({
      "categories": FieldValue.arrayRemove([key])
    });
    return false;
  }

  ///=======================================================
  static Future<bool> addNewUnit(String unit) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().update({
      "units": FieldValue.arrayUnion([unit])
    });
    return true;
  }

  ///=======================================================
  static Future<bool> addPhoneNumber(String clientId, String phone) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().collection("clients").doc(clientId).update({
      "phones": FieldValue.arrayUnion([phone])
    });
    return true;
  }

  static Future<bool> deletePhoneNumber(String clientId, String phone) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().collection("clients").doc(clientId).update({
      "phones": FieldValue.arrayRemove([phone])
    });
    return true;
  }

  static Future<bool> updateClientData(String clientId, Map<Object, Object?> data) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().collection("clients").doc(clientId).update(data);
    return true;
  }

  static Future<bool> deleteClient(String clientId) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc().collection("clients").doc(clientId).delete();
    return false;
  }
}



class Firestore {
  static final CollectionReference<Map<String, dynamic>> usersCollection =
    FirebaseFirestore.instance.collection("users");

  static DocumentReference userDoc =
    usersCollection.doc(UserData.uid);

  static CollectionReference clientsCollection =
    userDoc.collection("clients");

  static CollectionReference invoicesCollection =
    userDoc.collection("invoices");

  static CollectionReference invDetailsCollection =
    userDoc.collection("invDetails");

  static CollectionReference paymentsCollection =
    userDoc.collection("payments");

  void setCollections() {
    userDoc = usersCollection.doc(UserData.uid);
    clientsCollection = userDoc.collection("clients");
    invoicesCollection = userDoc.collection("invoices");
    invDetailsCollection = userDoc.collection("invDetails");
    paymentsCollection = userDoc.collection("payments");
  }

  ///=======================================================
  static String getId() => userDoc.collection("_").doc().id;
  ///=======================================================
  static Future<bool> uploadUserData(String mpName, String? mpLogo) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.set({
      "mpName": mpName,
      if (mpLogo != null) "mpName": mpName,
      "categories": {},
      "units": []
    });
    return true;
  }

  static Future<Object?> getUserData() async {
    if (!Shared.isConnected(false)) return false;
    return (await userDoc.get()).data();
  }

  static Future<bool> updateMpLogo(String? logoUrl) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.update({"mpLogo": logoUrl ?? FieldValue.delete()});
    return true;
  }

  static Future<bool> updateMpName(String name) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.update({"mpName": name});
    return true;
  }

  ///=======================================================
  static Future<bool> uploadClientDoc(ClientModel clientModel) async {
    if (!Shared.isConnected(true)) return false;

    await clientsCollection.doc(clientModel.id).set(clientModel.toJson());
    return true;
  }

  static Future<List<ClientModel>> getAllClients() async {
    if (!Shared.isConnected(true)) return [];

    try {
      QuerySnapshot<Object?> querySnapshot = await clientsCollection.get();
      return querySnapshot.docs.map((e) => ClientModel.fromJson(e.data())).toList();
    } on FirebaseException {
      return [];
    } catch(e) {
      return [];
    }
  }

  ///=======================================================
  static Future<bool> uploadInvoiceDoc(InvoiceModel invoice) async {
    if (!Shared.isConnected(true)) return false;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.set(invoicesCollection.doc(invoice.id), invoice.toJson());
    batch.set(invDetailsCollection.doc(invoice.id), invoice.detailsToJson());

    String ref =
      invoice.type == InvoiceTypes.returned? "totalRetTrans": "totalNorTrans";

    batch.update(clientsCollection.doc(invoice.clientId),
        {"transPayments.$ref": FieldValue.increment(invoice.priceAfterDiscount)});

    await batch.commit();
    return true;
  }

  static Future<List<InvoiceModel>> getClientInvoices(String clientId) async {
    if (!Shared.isConnected(false)) return [];

    QuerySnapshot<Object?> querySnapshot =
      await invoicesCollection.where("clientId", isEqualTo: clientId).get();

    return querySnapshot.docs.map((e) =>
      InvoiceModel.fromJson(e.id, e.data())).toList();
  }

  static Future<dynamic> getInvoiceDetails(String invoiceId) async {
    if (!Shared.isConnected(true)) return null;

    return (await invDetailsCollection.doc(invoiceId).get()).data();
  }

  static Future<bool> deleteInvoice(InvoiceModel invoice) async {
    if (!Shared.isConnected(true)) return false;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.delete(invoicesCollection.doc(invoice.id));
    batch.delete(invDetailsCollection.doc(invoice.id));

    String ref =
      invoice.type == InvoiceTypes.returned? "totalRetTrans": "totalNorTrans";

    batch.update(clientsCollection.doc(invoice.clientId),
      {"transPayments.$ref": FieldValue.increment(-invoice.priceAfterDiscount)});

    await batch.commit();
    return true;
  }

  static Future<bool> updateInvDetails(String invoiceId, dynamic data) async {
    if (!Shared.isConnected(true)) return false;

    await invDetailsCollection.doc(invoiceId).update(data);
    return true;
  }

  ///=======================================================
  static Future<bool> uploadPaymentDoc(PaymentModel payment) async {
    if (!Shared.isConnected(true)) return false;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.set(paymentsCollection.doc(payment.id), payment.toJson());

    String ref = payment.isNorm? "totalNorPay": "totalRetPay";

    batch.update(clientsCollection.doc(payment.clientId),
      {"transPayments.$ref": FieldValue.increment(payment.amount)});

    await batch.commit();
    return true;
  }

  static Future<List<PaymentModel>> getClientPayments(String clientId) async {
    if (!Shared.isConnected(false)) return [];

    QuerySnapshot<Object?> querySnapshot =
      await paymentsCollection.where("clientId", isEqualTo: clientId).get();

    return querySnapshot.docs.map((e) =>
      PaymentModel.fromJson(e.id, e.data())).toList();
  }

  static Future<bool> deletePayment(PaymentModel payment) async {
    if (!Shared.isConnected(true)) return false;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.delete(paymentsCollection.doc(payment.id));

    String ref = payment.isNorm? "totalNorPay": "totalRetPay";

    batch.update(clientsCollection.doc(payment.clientId),
      {"transPayments.$ref": FieldValue.increment(-payment.amount)});

    await batch.commit();
    return true;
  }

  static Future<List<PaymentModel>> getFutureDues() async {
    if (!Shared.isConnected(true)) return [];

    QuerySnapshot<Object?> querySnapshot =
    await paymentsCollection
      .where("dueDate", isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
      .get();

    return querySnapshot.docs.map((e) =>
      PaymentModel.fromJson(e.id, e.data())).toList();
  }

  ///=======================================================
  static Future<bool> updateCategory(int key, String category) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.update({"categories.$key": category});
    return true;
  }

  static Future<bool> deleteCategory(int key) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.update({"categories.$key": FieldValue.delete()});
    return true;
  }

  static Future<bool> addClientCategories(String clientId, List<int> categoriesId) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc
      .collection("clients")
      .doc(clientId)
      .update({"categories": FieldValue.arrayUnion(categoriesId)});
    return true;
  }

  static Future<bool> deleteClientCategory(String clientId, int key) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.collection("clients").doc(clientId).update({
      "categories": FieldValue.arrayRemove([key])
    });
    return false;
  }

  ///=======================================================
  static Future<bool> addNewUnit(String unit) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.update({
      "units": FieldValue.arrayUnion([unit])
    });
    return true;
  }

  ///=======================================================
  static Future<bool> addPhoneNumber(String clientId, String phone) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.collection("clients").doc(clientId).update({
      "phones": FieldValue.arrayUnion([phone])
    });
    return true;
  }

  static Future<bool> deletePhoneNumber(String clientId, String phone) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.collection("clients").doc(clientId).update({
      "phones": FieldValue.arrayRemove([phone])
    });
    return true;
  }

  static Future<bool> updateClientData(String clientId, Map<Object, Object?> data) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.collection("clients").doc(clientId).update(data);
    return true;
  }

  static Future<bool> deleteClient(String clientId) async {
    if (!Shared.isConnected(true)) return false;

    await userDoc.collection("clients").doc(clientId).delete();
    return false;
  }
}

