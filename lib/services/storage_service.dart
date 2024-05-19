import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  StorageService();

  Future<String?> uploadPfp({required File file, required String uid}) async {
    Reference reference = firebaseStorage.ref('/users/pfps').child('$uid${path.extension(file.path)}');
    UploadTask task = reference.putFile(file);

    try {
      final taskSnapshot = await task;
      if (taskSnapshot.state == TaskState.success) {
        return await reference.getDownloadURL();
      } else {
        throw Exception('Upload failed: ${taskSnapshot.state}');
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }


  Future<String?> uploadImageToChat({required File file,required String chatID})async{
    Reference fileReference=firebaseStorage.ref("chat/$chatID")
        .child('${DateTime.now().toIso8601String()}${path.extension(file.path)}');

    UploadTask task=fileReference.putFile(file);
    return task.then((p0){
      if(p0.state==TaskState.success){
        return fileReference.getDownloadURL();
      }
    });
  }
}