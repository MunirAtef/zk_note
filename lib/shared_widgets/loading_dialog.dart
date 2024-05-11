
import 'package:flutter/material.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';


showLoading({
  required BuildContext context,
  String title = "LOADING",
  Color color = MainColors.appColorDark,
  required Future<void> Function() waitFor
}) {
  showDialog(
    context: context,
    builder: (context) => LoadingBox(
      title: title,
      color: color,
      waitFor: waitFor
    )
  );
}


class LoadingBox extends StatelessWidget {
  final String title;
  final Color color;
  final Future<void> Function() waitFor;


  const LoadingBox({
    Key? key,
    required this.title,
    this.color = MainColors.appColorDark,
    required this.waitFor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    Future.delayed(Duration.zero, () async {
      NavigatorState navigator = Navigator.of(context);
      await waitFor();
      navigator.pop();
    });

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(vertical: 70),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),

        content: CustomContainer(
          width: width - 80,
          height: 150,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                ),
              ),

              const SizedBox(height: 20),
              CircularProgressIndicator(color: color),
            ],
          ),
        ),
      ),
    );
  }
}
