

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zk_note/firebase/firestore.dart';
import 'package:zk_note/screens/clients_list/clients_list_cubit.dart';
import 'package:zk_note/shared/user_data.dart';

import '../home_page/home_page_ui.dart';

class Marketplace {
  String uid;
  String mpName;
  String? mpLogo;

  Marketplace({required this.uid, required this.mpName, required this.mpLogo});

  factory Marketplace.fromJson(String uid, dynamic json) => Marketplace(
    uid: uid,
    mpName: json["mpName"],
    mpLogo: json["mpLogo"]
  );
}


class AdminCubit extends Cubit<int> {
  AdminCubit(): super(0);

  List<Marketplace>? users;

  void getUsers() async {
    users = null;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> querySnapshot =
      (await Firestore.usersCollection.get()).docs;

    users = querySnapshot.map((e) => Marketplace.fromJson(e.id, e.data())).toList();

    emit(1);
  }

  Future<void> cancel() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await UserData.getData(user.uid);
    Fluttertoast.showToast(msg: "Cleared");
  }

  void onTap(BuildContext context, int index) async {
    NavigatorState navigator = Navigator.of(context);
    ClientsListCubit clientsListCubit = ClientsListCubit.getInstance(context);
    bool isRegistered = await UserData.getData(users![index].uid);

    if (!isRegistered) {
      Fluttertoast.showToast(msg: "User is not registered");
      return;
    }

    clientsListCubit.clientModels = null;
    navigator.push(
        MaterialPageRoute(builder: (context) => const HomePage())
    );
  }
}
