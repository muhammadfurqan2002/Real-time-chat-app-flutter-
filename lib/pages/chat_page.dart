import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/storage_service.dart';

class ChatPage extends StatefulWidget {
  final UserProfile userProfile;
  const ChatPage({super.key,required this.userProfile});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatUser? currentUser,otherUser;
  final GetIt getIt=GetIt.instance;
  late AuthService _authService;
  late DataBaseService _dataBaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService=getIt.get<AuthService>();
    _dataBaseService=getIt.get<DataBaseService>();
    _mediaService=getIt.get<MediaService>();
    _storageService=getIt.get<StorageService>();
    currentUser=ChatUser(id: _authService.user!.uid,firstName: _authService.user!.displayName);
    otherUser=ChatUser(id: widget.userProfile.uid!,
        firstName: widget.userProfile.name,
        profileImage: widget.userProfile.pfpURL
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userProfile.name!),
      ),
      body: _buildUI(),
    );
  }
  Widget _buildUI(){
    return StreamBuilder(
        stream: _dataBaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context,snapshot){
          Chat? chat= snapshot.data?.data() as Chat;
          print(chat.messages);
          List<ChatMessage> messages=[];
          if(chat!=null && chat.messages!=null){
            messages=_generateChatMessage(chat.messages!);
          }
          return DashChat(
              messageOptions:const MessageOptions(
                  showOtherUsersAvatar: true,
                  showTime: true
              ),

              inputOptions: InputOptions(alwaysShowSend: true,autocorrect: true,
                  trailing: [
                    _mediaButton(),
                  ]
              ),
              currentUser: currentUser!,
              onSend:_sendMessage,
              messages:messages
          );
        });
  }

  Future<void> _sendMessage(ChatMessage chatMessage)async{

    if(chatMessage.medias?.isNotEmpty??false){
      if(chatMessage.medias!.first.type==MediaType.image){
        Message message=Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType:MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _dataBaseService.sendChatMessage(currentUser!.id, otherUser!.id, message);
      }
    }else{
      Message message=Message(
          senderID: currentUser!.id,
          content: chatMessage.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt)
      );
      await _dataBaseService.sendChatMessage(currentUser!.id, otherUser!.id, message);
    }

  }

  List<ChatMessage> _generateChatMessage(List<Message> messages){
    List<ChatMessage> chatMessages=messages.map((e){
      if(e.messageType==MessageType.Image){
        return ChatMessage(
          medias: [
            ChatMedia(url: e.content!, fileName: "", type: MediaType.image),
          ],
            user:e.senderID == currentUser!.id ?currentUser!:otherUser!,
            createdAt:e.sentAt!.toDate());
      }else{
        return ChatMessage(
            text: e.content!,
            user: e.senderID == currentUser!.id ?currentUser!:otherUser!,
            createdAt:e.sentAt!.toDate());
      }

    }).toList();
    chatMessages.sort((a,b){
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaButton(){
    return GestureDetector(
          onTap: ()async{
           File? file= await _mediaService.getImageFile();
               if(file!=null){
                 String chatID=generateChatId(uid1: currentUser!.id, uid2:otherUser!.id);
                    String? downloadUrl=await _storageService.uploadImageToChat(file: file, chatID: chatID);
                    print(downloadUrl);

                    if(downloadUrl!=null){
                      ChatMessage chatMessage=ChatMessage(user: currentUser!, createdAt: DateTime.now(),
                      medias: [ChatMedia(url:downloadUrl, fileName: "", type: MediaType.image)]
                      );
                      _sendMessage(chatMessage);
                    }
               }
          },
        child: Icon(Icons.image,color: Theme.of(context).colorScheme.primary,));
  }

}
