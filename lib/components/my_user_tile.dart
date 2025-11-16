import 'package:flutter/material.dart';
import 'package:twithub/models/user.dart';

import '../screen/profile_screen.dart';

class MyUserTile extends StatelessWidget {
  final UserProfile user;

  const MyUserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          radius: 22,
          child: const Icon(Icons.person, color: Colors.white, size: 26),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '@${user.username}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 18,
        ),
        onTap: () {
          // You can navigate to ProfileScreen here if you want:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(uid: user.uid),
            ),
          );
        },
      ),
    );
  }
}
