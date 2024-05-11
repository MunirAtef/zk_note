
import 'package:flutter/material.dart';
import 'package:zk_note/shared/main_colors.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final void Function()? onPressed;
  final String text;
  final Widget? leading;
  final double width;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool isLoading;
  final BorderRadiusGeometry borderRadius;


  const CustomButton({
    super.key,
    this.color = Colors.blue,
    this.text = "",
    this.leading,
    this.width = double.infinity,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.margin = const EdgeInsets.fromLTRB(40, 10, 40, 20),
    this.isLoading = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(30)),
    required this.onPressed
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      child: OutlinedButton(
        onPressed: isLoading? null: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            width: 2,
            color: Colors.white
          ),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),

          padding: const EdgeInsets.all(0),
          elevation: 8
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isLoading? Colors.grey[900]!: MainColors.appColorDark,
                isLoading? Colors.grey[600]!: color,
              ]
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: isLoading? const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(color: Colors.white),
                ) : leading
              ),

              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white
                ),
              ),

              const SizedBox(width: 40)
            ],
          ),
        ),
      ),
    );
  }
}

