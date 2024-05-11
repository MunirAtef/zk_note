
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zk_note/shared/shared_functions.dart';
import 'package:zk_note/shared/user_data.dart';

class StoragePaths {
  static String client(String clientId, String fileName) =>
    "${UserData.uid}/clients/$clientId-$fileName";
  static String user(String fileName) => "${UserData.uid}/$fileName";
}


class Storage {
  static final FirebaseStorage instance = FirebaseStorage.instance;

  static Future<String?> uploadFile({required String path, required File? file}) async {
    if (file == null) return null;
    if (!Shared.isConnected(false)) return null;

    Reference storageReference = instance.ref().child(path);

    TaskSnapshot uploadTask = await storageReference.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}

