import 'package:chat_app/models/user.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final UserProfile profile;
  final Function onTap;
  const ChatTile({super.key,required this.profile,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap:(){
        onTap();
      },
      dense: false,
      title: Text(profile.name!),
      leading: CircleAvatar(
        backgroundImage: NetworkImage("https://firebasestorage.googleapis.com/v0/b/blogapp-5a80b.appspot.com/o/users%2Fpfps%2Fr77fvyxodpYioU65rd7vaeDWdVN2.jpg?alt=media&token=f29b1809-c47d-4da6-b7eb-cdeb3de79a7c"),
      ),
    );
  }
}
