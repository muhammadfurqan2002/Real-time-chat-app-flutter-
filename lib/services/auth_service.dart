import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService{
  final FirebaseAuth auth=FirebaseAuth.instance;
  AuthService(){
    auth.authStateChanges().listen(authStateChangesStreamListener);
  }

  User? _user;

  User? get user{
    return _user;
  }

  Future<bool> login(String email,String password)async{
    try{
      final credential=await auth.signInWithEmailAndPassword(email: email, password: password);
      if(credential.user!=null){
        _user=credential.user;
        return true;
      }
    }catch(error){
      print(error);
    }
    return false;
  }

  Future<bool> signup(String email,String password)async{
    try{
      final credential=await auth.createUserWithEmailAndPassword(email: email, password: password);
      if(credential.user!=null){
        _user=credential.user;
        return true;
      }
    }catch(error){
      print(error);
    }
    return false;
  }


  void authStateChangesStreamListener(User? user){
    if(user!=null){
      _user=user;
    }else{
      user=null;
    }
  }

  Future<bool> logout()async{
    try{
      await auth.signOut();
      return true;
    }catch(e){
      print(e);
    }
    return false;
  }

}