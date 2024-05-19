
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/register_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationService{
  late GlobalKey<NavigatorState> navigatorKey;

  final Map<String,Widget Function(BuildContext)>_routes={
    "/login": (context) => LoginPage(),
    "/home": (context) => HomePage(),
    "/register": (context) => Register(),
  };


  GlobalKey<NavigatorState>? get _navigatorKey{
    return navigatorKey;
  }

  void Spush(MaterialPageRoute route){
    _navigatorKey?.currentState?.push(route);
  }

  Map<String,Widget Function(BuildContext)> get routes {
    return _routes;
  }


  NavigationService(){
    navigatorKey=GlobalKey<NavigatorState>();
  }

  void push(String routeName){
    navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName){
    navigatorKey.currentState?.pushReplacementNamed(routeName);
  }
  void goBack(){
    navigatorKey.currentState?.pop();
  }
}