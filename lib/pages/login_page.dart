import 'package:chat_app/consts.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GetIt  getIt=GetIt.instance;
  late AuthService _authService;
  final GlobalKey<FormState> _loginKey=GlobalKey();
  late NavigationService _navigationService;
  late AlertService alertService;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService=getIt.get<AuthService>();
    _navigationService=getIt.get<NavigationService>();
    alertService=getIt.get<AlertService>();
  }

  String? email,password;
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
          Text("Hi, Welcome Back!",style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),),
          Text("Hello again, you've been missed",style: TextStyle(
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
      height: MediaQuery.of(context).size.height*.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height*0.05,
      ),child:Form(
        key:_loginKey ,
        child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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

  Widget _loginButton(){
    return SizedBox(
      width:MediaQuery.of(context).size.width,
      child:MaterialButton(
          onPressed: ()async{
            if(_loginKey.currentState?.validate()?? false){
                  _loginKey.currentState?.save();
                  final result =await _authService.login(email!, password!);
                  if(result){
                    _navigationService.pushReplacementNamed('/home');
                  }else{}
            }
          },
        color: Theme.of(context).colorScheme.primary,
        child:const Text("Login",style: TextStyle(
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
        const Text("Don't have an account? "),
        GestureDetector(
          onTap: (){
            _navigationService.push("/register");
          },
          child:const Text("Sign Up",style: TextStyle(
            fontWeight: FontWeight.w800
          ),),
        ),

      ],
    ));
  }
}
