import 'package:flutter/material.dart';


class CustomFormField extends StatelessWidget {
  final String hintText;
  final double height;
  final RegExp validRegEx;
  final bool obsecure;
  final void Function(String?) onSaved;
  const CustomFormField({super.key,required this.onSaved,this.obsecure=false,required this.hintText,required this.height,required this.validRegEx});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        onSaved: onSaved,
        obscureText: obsecure,
        validator: (value){
          if(value!=null && validRegEx.hasMatch(value)){
            return null;
          }
          return 'Enter a valid ${hintText.toLowerCase()}';
        },
        decoration: InputDecoration(
          hintText: hintText,
          border:const OutlineInputBorder(),
        ),
      ),
    );
  }
}
