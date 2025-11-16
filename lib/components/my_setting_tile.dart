import 'package:flutter/material.dart';

class MySettingTile extends StatelessWidget {
  final String title;
  final Widget action;

  const MySettingTile({super.key, required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      padding: EdgeInsets.all(10),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        trailing: action,
      ),
    );
  }
}
