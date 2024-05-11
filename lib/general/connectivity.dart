
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:zk_note/shared_widgets/custom_snake_bar.dart';

class ConnectivityCheck {
  static bool isConnected = true;
  static StreamSubscription<ConnectivityResult>? subscription;

  static connectivityListener(BuildContext context) {
    subscription ??= Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result.index == ConnectivityResult.none.index) {
        isConnected = false;

        CustomSnackBar(
          context: context,
          subColor: Colors.grey[800]!,
          mainColor: Colors.black
        ).show("No internet connection");
      } else {
        if (!isConnected) {
          isConnected = true;

          CustomSnackBar(context: context).show("Connected to internet");
        }
      }
    });
  }
}
