
import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';
import '../consts.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../widgets/custom_form_field.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GetIt  getIt=GetIt.instance;
  late AuthService _authService;
  final GlobalKey<FormState> _loginKey=GlobalKey();
  late NavigationService _navigationService;
  late AlertService alertService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late DataBaseService _dataBaseService;
  File? profileImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService=getIt.get<AuthService>();
    _navigationService=getIt.get<NavigationService>();
    alertService=getIt.get<AlertService>();
    _mediaService=getIt.get<MediaService>();
    _storageService=getIt.get<StorageService>();
    _dataBaseService=getIt.get<DataBaseService>();
  }

  String? email,password,name;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUi(),
    );
  }


  Widget _buildUi(){
    return SafeArea(child:Padding(padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 20.0),
      child: Column(
        children: [
          _headerText(),
          _loginForm(),
          _createAccount()
        ],
      ),
    ));
  }


  Widget _headerText(){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child:const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's, get going!",style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),),
          Text("Register an account using the form below",style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey
          ),),
        ],
      ),
    );
  }

  Widget _loginForm(){
    final h=MediaQuery.of(context).size.height;
    final w=MediaQuery.of(context).size.width;
    return Container(
      // color: Colors.amber,
      // height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height*0.05,
      ),child:Form(
        key:_loginKey ,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            _pfp(),
            const SizedBox(height: 20,),
            CustomFormField(
              onSaved: (value){
                name=value;
              },hintText:"Name",height:h*0.1 ,validRegEx: NAME_VALIDATION_REGEX,),

            CustomFormField(
              onSaved: (value){
                email=value;
              },hintText:"Email",height:h*0.1 ,validRegEx: EMAIL_VALIDATION_REGEX,),

            CustomFormField(
              onSaved: (value){
                setState(() {
                  password=value;
                });
              },
              obsecure: true,hintText:"Password",height:h*0.1 ,validRegEx: PASSWORD_VALIDATION_REGEX,),
            _loginButton()
          ],
        )),
    );
  }


  Widget _pfp(){
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: GestureDetector(
        onTap: ()async{
          try{
            File? file=await _mediaService.getImageFile();


            if(file!=null){
              setState(() {
                profileImage=file;
              });
            }
          }catch(e){
            print(e);
          }

        },
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.width*.15,
          backgroundImage:profileImage!=null?FileImage(profileImage!):NetworkImage(PLACEHOLDER_PFP) as ImageProvider ,
        ),
      ),
    );
  }

  Widget _loginButton(){
    return SizedBox(
      width:MediaQuery.of(context).size.width,
      child:MaterialButton(
        onPressed: ()async{
          try{
          if(_loginKey.currentState?.validate()?? false){
            _loginKey.currentState?.save();
              bool result=await _authService.signup(email!, password!);
              if(result) {
                print(_authService.user!.uid);
                  String? pfpURL=await _storageService.uploadPfp(
                      file: profileImage!, uid: _authService.user!.uid);
                  if(pfpURL!=null){
                    await _dataBaseService.createUserProfile(userProfile: UserProfile(uid: _authService.user!.uid, name: name, pfpURL: pfpURL));
                    alertService.showToast(text: "User registered Successfully!",icon: Icons.check);
                    _navigationService.goBack();
                    _navigationService.pushReplacementNamed("/home");
                  }else{

                    throw Exception("Unable to upload user profile picture");
                  }

              }else{
                throw Exception("Unable to register user");
              }
          }}catch(e){
            alertService.showToast(text: "Failed to register, Please try again!",icon: Icons.dangerous_outlined);
          }
        },
        color: Theme.of(context).colorScheme.primary,
        child:const Text("Register",style: TextStyle(
            color: Colors.white
        ),) ,
      ),
    );
  }


  Widget _createAccount(){
    return  Expanded(child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: (){
                _navigationService.goBack();
          },
          child:const Text("Login",style: TextStyle(
              fontWeight: FontWeight.w800
          ),),
        ),

      ],
    ));
  }
}
