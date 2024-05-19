import 'package:image_picker/image_picker.dart';
import 'dart:io';
class MediaService{
  final ImagePicker picker=ImagePicker();
  MediaService(){}

  Future<File?> getImageFile()async{
    final XFile? file=await picker.pickImage(source: ImageSource.gallery);

    if(file!=null){
      return File(file.path);
    }else{
      return null;
    }
  }
}