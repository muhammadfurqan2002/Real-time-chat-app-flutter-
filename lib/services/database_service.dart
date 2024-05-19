import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'auth_service.dart';

class DataBaseService{
  final FirebaseFirestore firebaseFirestore=FirebaseFirestore.instance;
  CollectionReference? usersCollection;
  CollectionReference? chatCollection;
  final GetIt getIt=GetIt.instance;
  late AuthService authService;

  DataBaseService(){
    authService=getIt.get<AuthService>();
    _setupCollectionReference();
  }


  void _setupCollectionReference(){
      usersCollection=firebaseFirestore.collection("users").withConverter<UserProfile>(
          fromFirestore: (snapshots,_)=>UserProfile.fromJson(
            snapshots.data()!,
          ),
          toFirestore: (userProfile,_)=>userProfile.toJson());

      chatCollection=firebaseFirestore.collection("chats").withConverter<Chat>(
          fromFirestore:(snapshots,_)=>Chat.fromJson(
              snapshots.data()!),
          toFirestore: (chat,_)=>chat.toJson());
  }

  Future<void> createUserProfile({required UserProfile userProfile})async{
    await usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles(){
    return usersCollection?.where("uid",isNotEqualTo:authService.user!.uid ).
            snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExist (String uid1,String uid2)async{
    String chatID=generateChatId(uid1: uid1, uid2: uid2);
    final result= await chatCollection!.doc(chatID).get();
    if(result!=null){
      return result.exists;
    }else{
      return false;
    }
  }

  Future<void> createNewChat(String uid1,String uid2)async{
    String chatID=generateChatId(uid1: uid1, uid2: uid2);
    final result= await chatCollection!.doc(chatID).get();
   final docRef=chatCollection!.doc(chatID);
   final chat=Chat(id: chatID, participants:[uid1,uid2], messages: []);
   await docRef.set(chat);
  }
  Future<void> sendChatMessage(String uid1,String uid2,Message message)async{
    String chatID=generateChatId(uid1: uid1, uid2: uid2);
    final docRef=chatCollection!.doc(chatID);
    await docRef.update({
      "messages":FieldValue.arrayUnion([message.toJson()],)
    });
  }

  Stream<DocumentSnapshot> getChatData(String uid1,String uid2){
    String chatID=generateChatId(uid1: uid1, uid2: uid2);
    return chatCollection!.doc(chatID).snapshots() as Stream<DocumentSnapshot<Chat?>>;
  }
}