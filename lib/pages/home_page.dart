import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/auth_service.dart';
import '../services/navigation_service.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt  getIt=GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late DataBaseService _dataBaseService;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService=getIt.get<AuthService>();
    _navigationService=getIt.get<NavigationService>();
    _dataBaseService=getIt.get<DataBaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
        actions: [
          IconButton(onPressed: ()async{
            bool result=await _authService.logout();
            if(result){
              _navigationService.pushReplacementNamed('/login');
            }else{

            }
          },color: Colors.red, icon: Icon(Icons.logout))
        ],
      ),
      body: _buildUI(),
    );
  }
  Widget _buildUI(){
    return SafeArea(child:Padding(padding: EdgeInsets.symmetric(
      horizontal: 15,vertical: 20
    ),child: _chatList(),));
  }

  Widget _chatList(){
    return StreamBuilder(stream: _dataBaseService.getUserProfiles(),
        builder:(context,snapshot){
          if(snapshot.hasError){
            return const Center(child: Text("Unable to load data."),);
          }
          if(snapshot.hasData){
            final user=snapshot.data!.docs;
            print(user.length);
            return ListView.builder(
                itemCount: user.length,
                itemBuilder: (context,index){
                    return ChatTile(profile: user[index].data(), onTap: ()async{
                      final chatExists=await _dataBaseService.checkChatExist(_authService.user!.uid, user[index].data().uid!);
                          if(!chatExists){
                                  await _dataBaseService.createNewChat(_authService.user!.uid, user[index].data().uid!);
                          }
                          _navigationService.Spush(MaterialPageRoute(builder:(context)=>ChatPage(userProfile: user[index].data()) ));
                    });
                });
          }
         return  const Center(child: CircularProgressIndicator(),);
        });
  }
}
