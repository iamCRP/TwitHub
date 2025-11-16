import 'package:flutter/material.dart';

class MyProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  final void Function()? onTap;

  const MyProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    //textStyle for count
    var textStyleForCount = TextStyle(
      fontSize: 20,
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    //textStyle for text
    var textStyleForText = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(postCount.toString(), style: textStyleForCount),
              Text('Posts', style: textStyleForText),
            ],
          ),
          Column(
            children: [
              Text(followerCount.toString(), style: textStyleForCount),
              Text('Followers', style: textStyleForText),
            ],
          ),
          Column(
            children: [
              Text(followingCount.toString(), style: textStyleForCount),
              Text('Following', style: textStyleForText),
            ],
          ),
        ],
      ),
    );
  }
}
