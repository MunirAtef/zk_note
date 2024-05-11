
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';

import '../shared/main_colors.dart';
import 'custom_button.dart';

class UploadImage extends StatelessWidget {
  final File? imageFile;
  final Color color;
  final void Function(BuildContext) onUploadImage;

  const UploadImage({
    Key? key,
    required this.imageFile,
    this.color = MainColors.appColorLight,
    required this.onUploadImage
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return CustomContainer(
      borderRadius: const BorderRadius.all(Radius.circular(20)),

      child: Stack(
        clipBehavior: Clip.none,
        children: [
          imageFile != null? ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Image.file(
              imageFile!,
              width: width * 3 / 5,
              height: width * 3 / 7,
              fit: BoxFit.cover,
            ),
          ): SizedBox(width: width * 3 / 5, height: width * 3 / 7),

          Positioned(
            bottom: -1,
            child: SizedBox(
              width: width * 3 / 5,
              child: CustomButton(
                onPressed: () => onUploadImage(context),
                padding: const EdgeInsets.all(5),
                margin: EdgeInsets.zero,
                text: "UPLOAD IMAGE",
                color: color,
                leading: const Icon(Icons.add_a_photo, color: Colors.white),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20)
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}

