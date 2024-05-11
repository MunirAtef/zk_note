
import 'package:flutter/material.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';
import '../../shared/main_colors.dart';

class LoginBackground extends StatelessWidget {
  final Widget? body;

  const LoginBackground({
    Key? key,
    this.body
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MainColors.appColorDark,
              MainColors.addClientPage,
              MainColors.clientsListPage
            ]
          )
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: CustomContainer(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 30),
            shadowColor: Colors.grey[800]!,
            width: double.infinity,
            child: body,
          ),
        ),
      ),
    );
  }
}
