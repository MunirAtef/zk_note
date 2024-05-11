
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';

class PickImage {
  static Future<File?> pickImage({
    required BuildContext context,
    Color color = MainColors.appColorDark,
    void Function()? onDelete
  }) async {
    File? pickedImage;
    bool pickingOff = true;

    await showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async { return pickingOff; },

          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: const EdgeInsets.symmetric(vertical: 70),
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),

            content: CustomContainer(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      "UPLOAD IMAGE",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ListTile(
                    title: const Text(
                      "FROM DEVICE",
                      style: TextStyle(
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    leading: Icon(Icons.image, color: color),
                    onTap: () async {
                      pickingOff = false;
                      NavigatorState navigator = Navigator.of(context);
                      pickedImage = await _getImage(true);
                      navigator.pop();
                    },
                  ),

                  ListTile(
                    title: const Text(
                      "FROM CAMERA",
                      style: TextStyle(
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    leading: Icon(Icons.camera_alt, color: color),
                    onTap: () async {
                      pickingOff = false;
                      NavigatorState navigator = Navigator.of(context);
                      pickedImage = await _getImage(false);
                      navigator.pop();
                    },
                  ),

                  if (onDelete != null)
                    ...[
                      const Divider(thickness: 2),

                      ListTile(
                        title: const Text(
                          "DELETE",
                          style: TextStyle(
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        leading: Icon(Icons.delete, color: color),
                        onTap: onDelete,
                      ),
                    ]
                ],
              ),
            ),

          ),
        );
      }
    );

    return pickedImage;
  }

  static Future<File?> _getImage(bool fromGallery) async {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: fromGallery? ImageSource.gallery: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800
    );

    // if (pickedImage == null) return null;
    //
    // CroppedFile? croppedFile = await ImageCropper().cropImage(
    //   sourcePath: pickedImage.path,
    //   aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    //   maxWidth: 500,
    //   maxHeight: 500,
    //   uiSettings: [AndroidUiSettings(
    //     toolbarTitle: 'Crop Image',
    //     toolbarColor: Colors.blue,
    //     toolbarWidgetColor: Colors.white,
    //   )],
    // );

    return pickedImage != null? File(pickedImage.path): null;
  }
}


